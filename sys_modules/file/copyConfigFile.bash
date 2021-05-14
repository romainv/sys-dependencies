# Import dependencies
# shellcheck source=./makeTempFile.bash
source "${BASH_SOURCE%/*}/makeTempFile.bash"

# Update a configuration file based on a source file
# Arg 1 (sourceFile): The most recent version of the file
# Arg 2 (targetFile): The file to update
# Arg 3 (checkOnly - optional) "true" to perform a check and no changes
copyConfigFile() {
	local sourceFile="$1"
	local targetFile="$2"
	local checkOnly="$3"
	# Create a temp copy of source file
	# File paths are considered to be relative to the module's package.json file
	sourceFile=$(makeTempFile "$sourceFile" "$targetFile") 
	# Replace parameters in source file 
	replaceParameters "$sourceFile" 
	# Override if necessary
	local output
	output=$(override "$sourceFile" "$targetFile" "$checkOnly") 
	local updated=$? # Retrieve exit code
	# Cleanup temp folder 
	[ -d "$(dirname "$sourceFile")" ] && rm -rf -- "$(dirname "$sourceFile")" 
	# Indicate if file was updated or not
	[ $updated -eq 0 ]
}
