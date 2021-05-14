# Import dependencies
# shellcheck source=./copyConfigFile.bash
source "${BASH_SOURCE%/*}/copyConfigFile.bash"
# shellcheck source=./addToConfigFile.bash
source "${BASH_SOURCE%/*}/addToConfigFile.bash"
# shellcheck source=./linkConfigFile.bash
source "${BASH_SOURCE%/*}/linkConfigFile.bash"
# shellcheck source=./iniConfigFile.bash
source "${BASH_SOURCE%/*}/iniConfigFile.bash"
# shellcheck source=./replaceParameters.bash
source "${BASH_SOURCE%/*}/replaceParameters.bash"

# Process a config file that may need to be created or updated
# Arg 1 (targetFile) The file to be updated
# Arg 2 (params) The JSON parameters for the config file
# Arg 3 (checkOnly - optional) "true" to perform a check and no changes
processConfigFile() {
	local targetFile="$1"
	local params="$2"
	local checkOnly="$3"
	# Set checkOnly if dry mode is on
	$SPM_DRY_RUN && checkOnly="true"
	# Retrieve action to perform
	local action
	action=$(jq -r "keys[] \
		| select(. | inside(\
			\"copy\", \
			\"addToFile\", \
			\"link\", \
			\"generate\", \
			\"ini\"))" \
		<<< "${params}" | head -n 1) # Select the first matching action
	# Perform requested action
	local updated=false # Will be true if an update was performed or is required
	case "$action" in
			addToFile) # If we need to add content to the destination file
				jq -r ".addToFile[] | @base64" <<< "${params}" \
					| addToConfigFile "$targetFile" "$checkOnly" \
					&& updated=true ;; 
			copy)	# If we need to copy a config file
				copyConfigFile \
					"$(jq -j ".copy" <<< "${params}")" \
					"$targetFile" \
					"$checkOnly" \
					&& updated=true ;; 
			generate) # If we need to generate a config file
				# Prepend 'true && ' to the command to distinguish it from a file path
				copyConfigFile \
					"true && $(jq -j ".generate" <<< "${params}")" \
					"$targetFile" \
					"$checkOnly" \
					&& updated=true ;;
			link) # If we need to make a symlink
				linkConfigFile \
					"$(jq -j ".link" <<< "${params}")" \
					"$targetFile" \
					"$checkOnly" \
					&& updated=true ;;
			ini) # If key-values are specified in INI format
				iniConfigFile \
					"$targetFile" \
					"$(jq -j ".ini" <<< "${params}")" \
					"$checkOnly" \
					&& updated=true ;;
			*) # If no action was specified
				echo "missing parameters"
				exit 1 ;;
		esac
	# Indicate whether there has been changes
	$updated
}
