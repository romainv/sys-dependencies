#!/bin/bash
# Manage updates to config files

# Import dependencies
# shellcheck source=./processConfigFile.bash
source "${BASH_SOURCE%/*}/processConfigFile.bash"
# shellcheck source=./decodeFilename.bash
source "${BASH_SOURCE%/*}/decodeFilename.bash"

checkInstall() {
	local targetFile="$1"
	# Decode special characters and syntax
	if ! targetFile=$(decodeFilename "$targetFile"); then
		echo "$targetFile" && exit 1
	fi
	[ -e "${targetFile/#\~/$HOME}" ] # Replace tilde with home path
}

runInstall() {
	local targetFile="$1"
	local params="$2"
	# Decode special characters and syntax
	if ! targetFile=$(decodeFilename "$targetFile"); then
		echo "$targetFile" && exit 1
	fi
	processConfigFile "$targetFile" "$params"
}

# There is no version to manage
getInstalledVersion() { true; } 
getLatestVersion() { true; } 

checkUpdates() { 
	local targetFile="$1"
	local params="$2"
	# Decode special characters and syntax
	if ! targetFile=$(decodeFilename "$targetFile"); then
		echo "$targetFile" && exit 1
	fi
	processConfigFile "$targetFile" "$params" "true" # Specify checkOnly=true
} 

runUpdates() {
	local targetFile="$1"
	local params="$2"
	# Decode special characters and syntax
	if ! targetFile=$(decodeFilename "$targetFile"); then
		echo "$targetFile" && exit 1
	fi
	processConfigFile "$targetFile" "$params"
}

postProcess() {
	local params="$2"
	local exitCode=1 # Will be turned to 0 if something was displayed
	if ! $SPM_DRY_RUN && [ "${MODULE_CHANGES:-0}" -gt 0 ]; then 
		# If file was updated
		# Command to run if target file gets updated
		local onUpdate
		onUpdate=$(jq -j ".onUpdate" <<< "${params}") 
		# Execute comnand if supplied
		if [[ -n "$onUpdate" && "$onUpdate" != "null" ]]; then
			eval "$onUpdate"
			exitCode=0 # Indicate something changed
		fi
	fi
	return $exitCode # Indicate nothing was displayed
}
