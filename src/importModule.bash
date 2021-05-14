# Declare global variables that are module-specific and should not be shared 
# across modules
# Required module exports
declare -a MODULE_EXPORTS=(\
	checkInstall \
	checkUpdates \
	runInstall \
	runUpdates \
	getInstalledVersion \
	getLatestVersion)
# Optional module exports
declare -a MODULE_EXPORTS_OPT=(preProcess postProcess) 

# Import a module's commands 
# Arg 1 (module) The module identifier or path
importModule() {
	local module="$1"
	# Unset module exports before sourcing them (otherwise they'd persist even 
	# when using local)
	local moduleExport=
	# Required imports
	for moduleExport in "${MODULE_EXPORTS[@]}"; do
		unset "$moduleExport"
	done 
	# Optional imports
	for moduleExport in "${MODULE_EXPORTS_OPT[@]}"; do
		unset "$moduleExport"
	done 
	# Retrieve full path to module's package.json file 
	local moduleJSON 
	if [[ "$module" == *".json" ]]; then
		# If module points at a JSON file, make sure its path is absolute
		moduleJSON=$(rel2abs "$module")
		MODULE_DIR=$(dirname "$moduleJSON")
		MODULE_NAME=${MODULE_DIR##*/}
	else
		# If a module id is provided (moduleId is either 'name' or 'type/name')
		MODULE_TYPE=${module%%/*} # Read first part of 'type/name'
		# Read second part of 'type/name' (or 'type' if no name)
		MODULE_NAME=${module#*/} 
		# Upsearch module location locally 
		if ! MODULE_DIR=$(upsearch "sys_modules/$MODULE_TYPE"); then
			# If module couldn't be found in the pwd hierarchy, revert to default
			MODULE_DIR="$SPM_DIR/sys_modules/$MODULE_TYPE"
		fi
		moduleJSON="$MODULE_DIR/package.json"
	fi
	export MODULE_DIR MODULE_TYPE MODULE_NAME
	# Check if module exists
	if [ ! -s "$MODULE_DIR" ]; then # If file is missing or empty
		echo "${RED}failed${NORMAL}"
		echo "$MODULE_DIR is either missing or empty"
		exit 1 
	fi
	# Check if module has a JSON description
	if [ ! -f "$moduleJSON" ]; then # If module's JSON file was not found
		echo "${RED}failed${NORMAL}"
		echo "${moduleJSON} was not found"
		exit 1 
	fi
	# Retrieve available sections from the module's JSON
	# jq being one of the dependencies, we need to check first if it is available
	if isCommand jq; then
		dependencies="$(jq -j ".sysDependencies" < "$moduleJSON")"
	fi
	# Ensure dependencies is an empty string if it is not available
	[[ "$dependencies" == "null" || "$dependencies" == "{}" ]] \
		&& dependencies=""
	# Import module commands if available
	if [[ -f "$MODULE_DIR/package.bash" ]]; then
		# shellcheck source=/dev/null
		if ! source "$MODULE_DIR/package.bash"; then
		# If something went wrong while sourcing file
			echo "${RED}failed${NORMAL}"
			echo "Error sourcing $MODULE_DIR/package.bash"
			exit 1 
		fi
		# Verify that all required exports are now defined
		for moduleExport in "${MODULE_EXPORTS[@]}"; do
			if [[ $(type -t "$moduleExport") != "function" ]]; then
				echo "${RED}failed${NORMAL}"
				echo "$moduleExport was not exported by module $MODULE_DIR"
				exit 1 
			fi
		done
	fi
}
