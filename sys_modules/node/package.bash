#!/bin/bash
# Installation of node

checkInstall() { 
	local branch="$1"
	local version="$2"
	local versionFile
	# Check if node command exists, and that the specified version is installed
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" &> /dev/null # Source nvm
	isCommand node && {
		if versionFile=$(cd "$PWD_BACKUP" && upsearch ".nvmrc"); then
			# If a version is configured in a .nvmrc file 
			version=$(cat "$versionFile")
			# Check if the version is installed (exit code >0 if not)
			nvm ls "$version" &> /dev/null
		else # If no version was configured in a .nvmrc file
			if [[ -n "$version" && "$version" != '*' ]]; then
				# If a specific version was provided
				nvm ls "$version" &> /dev/null
			elif [[ "$branch" != "node" ]]; then
				# If a specific branch was provided
				nvm ls"$branch" &> /dev/null
			else # No specific version required
				true 
			fi
		fi
	}
}

runInstall() {
	local branch="$1" 
	local version="$2"
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" &> /dev/null # Source nvm
	# Install specified version
	local versionToInstall
	versionToInstall=$(getLatestVersion "$branch" "$version")
	nvm install "$versionToInstall" 2>&1 
	nvm use "$versionToInstall" 2>&1 
}

# This retrieves the node version installed 
getInstalledVersion() { 
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" &> /dev/null # Source nvm
	# Remove leading 'v' before version number
	nvm version "current" | sed -E "s/v([0-9.]+)/\\1/g" 
}

# This retrieves the latest node version available in the configured lts branch
getLatestVersion() { 
	local branch="$1" 
	local version="$2"
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" # Source nvm
	local versionFile
	if versionFile=$(cd "$PWD_BACKUP" && upsearch ".nvmrc"); then
		# If a version is configured in a .nvmrc file 
		version=$(cat "$versionFile")
		if [[ "$version" == "lts/"* ]]; then
			# If a lts branch is specified, extract the branch name and list the
			# corresponding last version
			nvm ls-remote --lts="${version#*/}" \
				| sed -nE "s/.*v([0-9.]+).*Latest.*/\\1/p"
		else # If a specific version is specified
			echo "$version" # Return it unchanged
		fi
	else # If no version was configured in a .nvmrc file
		# Retrieve latest version, specifying branch if relevant
		if [[ "$branch" == "node" ]]; then # No branch specified
			if [[ -z "$version" || "$version" == '*' ]]; then
				# If no specific version was provider
				nvm ls-remote | tail -1 | sed -nE "s/.*v([0-9.]+).*/\\1/g"
			else
				# If a specific version was provider
				echo "$version"
			fi
		else # If a branch is specified
			nvm ls-remote --lts="$branch" \
				| sed -nE "s/.*v([0-9.]+).*Latest.*/\\1/p"
		fi
	fi
}

checkUpdates() {
	local branch="$1" 
	local version="$2"
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" # Source nvm
	# If the latest version is not installed
	! nvm ls "$(getLatestVersion "$branch" "$version")" | grep -qPo "v[0-9.]+"
}

runUpdates() {
	local branch="$1" 
	local version="$2"
	# Retrieve the latest available version
	local latestVersion
	latestVersion="$(getLatestVersion "$branch" "$version")" 
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" # Source nvm
	nvm install \
		"$latestVersion" \
		--reinstall-packages-from="$(getInstalledVersion)" 2>&1
	# Use the new nvm version for the rest of the script 
	nvm use "$latestVersion" 2>&1 
}

postProcess() {
	local branch="$1" 
	local version="$2"
	if ! $SPM_DRY_RUN; then # If we're not in dry run
		local latestVersion currentVersion
		# Retrieve the latest available version
		latestVersion=$(getLatestVersion "$branch" "$version")
		# Retrieve version in use
		currentVersion=$(getInstalledVersion "$branch" "$version") 
		if [[ "$currentVersion" != "$latestVersion" ]]; then 
			# If current version is not correct 
			# shellcheck source=/dev/null
			source "$HOME/.nvm/nvm.sh" &> /dev/null # Source nvm
			# Update nvm version for the rest of the script (e.g. to update the right 
			# npm)
			nvm use "$latestVersion" &> /dev/null 
			# Indicate if node version in use needs to be changed as 'nvm use' won't 
			# reflect in parent shell
			printf "%b " \
				"${YELLOW}${INFO_ICON}${INFO_ICON:+ }" \
				"Please run 'nvm use v$latestVersion'" \
				"(currently using v${currentVersion})${NORMAL}"
			true # Indicate something was displayed
		else
			false # Indicate nothing changed
		fi
	else
		false # Indicate nothing changed
	fi
}
