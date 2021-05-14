# Import dependencies
# shellcheck source=./importModule.bash
source "${BASH_SOURCE%/*}/importModule.bash"
# shellcheck source=./displayIcon.bash
source "${BASH_SOURCE%/*}/displayIcon.bash"
# shellcheck source=./processDependencies.bash
source "${BASH_SOURCE%/*}/processDependencies.bash"
# shellcheck source=./processParameter.bash
source "${BASH_SOURCE%/*}/processParameter.bash"
# shellcheck source=./installModule.bash
source "${BASH_SOURCE%/*}/installModule.bash"
# shellcheck source=./updateModule.bash
source "${BASH_SOURCE%/*}/updateModule.bash"
# shellcheck source=./unimportModule.bash
source "${BASH_SOURCE%/*}/unimportModule.bash"

# Process a module's JSON configuration
# Arg 1 (module) The module identifier or a path to a module's package.json 
# Arg 2 (version) The version requirement
processModule() {
	local module="$1"
	local version="$2"
	export MODULE_CHANGES=0 # Keep track of changes to the current module
	# Import module	
	local dependencies=""
	printf "loading %s... " "$module" | nowrap
	importModule "$module" # This will set the above local variables
	# Display current module
	local prefix
	prefix="$(displayIcon "$MODULE_TYPE" " ")$MODULE_NAME: "
	if [ -n "${IS_TERMINAL-}" ]; then 
		# If shell is interactive 
		printf "done%b%s\n" "${LINE_START}${CLEAR_LINE}" "$prefix" | nowrap
	else # If shell is not interactive
		printf "done\n%s\n" "$prefix" | nowrap
	fi
	# Note: below we use process substitution, i.e. > >(...) instead of pipes
	# because pipes run in subshells, which prevent setting global variables, 
	# and it is more tricky to evaluate if the first command failed, e.g. 
	# false | indent && echo 'true' displays 'true'
	# Pre-processing
	[[ "$(type -t preProcess)" == "function" ]] \
		&& preProcess "$MODULE_NAME" "$version" > >(indent 2) \
			&& MODULE_CHANGES=$((MODULE_CHANGES+1))
	# Process dependencies (run in subshell to isolate env variables, including
	# module commands)
	if [[ -n "$dependencies" ]]; then
		(processDependencies "$dependencies") > >(indent 2)
		local depStatus=$?
		# Propagate request to terminate parent shells
		[ $depStatus -eq 1 ] && exit 1 
		# Indicate there were changes
		[ ! $depStatus -eq 0 ] && MODULE_CHANGES=$((MODULE_CHANGES+1)) 
	fi
	# Run install/update commands
	if [[ "$(type -t checkInstall)" == "function" ]]; then 
		# If commands are defined (we check only one of the required commands)
		if [ $MODULE_CHANGES -eq 0 ] && {
			[[ -z "$dependencies" ]] || $SPM_HIDE_UNCHANGED
		} && [ -n "${IS_TERMINAL-}" ]; then
			# If nothing was displayed previously for current module, and shell is 
			# interactive: display commands inline
			printf "%b" "${CLEAR_PREVIOUS_LINE}${prefix}" | nowrap
		else
			# Otherwise display command output under a sub-line
			printf "status: " | indent 2 
		fi
		if $SPM_FORCE \
			|| ! checkInstall "$MODULE_NAME" "$version" > /dev/null 2>&1; then 
			# Run again in a subshell to capture output
			local result
			result=$(checkInstall "$MODULE_NAME" "$version" 2>&1)
			if [[ -n "$result" ]]; then
				printf "%b\n" "${RED}failed to check install${NORMAL}"
				printf "%s\n" "${result}" | indent 2
				exit 1
			fi
			# If module is not yet installed
			installModule "$MODULE_NAME" "$version" \
				&& MODULE_CHANGES=$((MODULE_CHANGES+1)) 
		else
			# If module is already installed 
 			if $SPM_UPDATE; then
 				# If update was requested
				updateModule "$MODULE_NAME" "$version" \
					&& MODULE_CHANGES=$((MODULE_CHANGES+1)) 
			else # If update was not requested, don't check for updates
				local installedVersion
				installedVersion=$(getInstalledVersion "$MODULE_NAME" "$version")
				[[ -n "$installedVersion" ]] \
					&& installedVersion=" (v${installedVersion})"
				echo "${GREY}already installed${installedVersion}${NORMAL}" | nowrap
			fi
		fi
	fi 
	# Post-processing
	[[ $(type -t postProcess) == "function" ]] \
		&& postProcess "$MODULE_NAME" "$version" > >(indent 2) \
			&& MODULE_CHANGES=$((MODULE_CHANGES+1)) 
	# Clean dependency import
	unimportModule 
	if [ $MODULE_CHANGES -eq 0 ]; then # If module had no changes
		# Hide if required
		$SPM_HIDE_UNCHANGED && echo -e "${CLEAR_PREVIOUS_LINE}${PREVIOUS_LINE}" 
		false # Indicate module had no changes
	else
		true # Indicate module has changes
	fi
}
