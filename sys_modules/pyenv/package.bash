#!/bin/bash
# shellcheck disable=SC2016
# The above disables checks on variables in single quotes
# This installs and updates pyenv

checkInstall() {
	# Check if pyenv command is available by adding its default location to the
	# path. This way we cover both situations where pyenv is already loaded
	# (regardless of its location) and cases where it is installed but not
	# available in path (e.g. in non-interactive shells)
	PATH="$HOME/.pyenv/bin:$PATH" isCommand pyenv
}

runInstall() {
	# Installation on MACOS is covered by brew, set as dependency
	if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
		local pyenvDir="$HOME/.pyenv"
		# Clean-up former installation
		[ -d "$pyenvDir" ] && rm -rf -- "$pyenvDir" 2>&1
		# Install pyenv
		curl https://pyenv.run 2>/dev/null | bash 2>&1 
		# Edit .bashrc file
		addToFile 'export PATH="$HOME/.pyenv/bin:$PATH"' ~/.bashrc
		addToFile 'eval "$(pyenv init -)"' ~/.bashrc
		# shellcheck source=/dev/null
		source ~/.bashrc
	fi
}

getInstalledVersion() {
	PATH="$HOME/.pyenv/bin:$PATH" pyenv --version 2>&1 \
		| sed -E "s/^pyenv (.*)/\1/" # Remove leading 'pyenv'
}

getLatestVersion() {
	# Retrieve releases info in JSON format and select the latest one
	# We remove the leading 'v' from the version number, if there is one, and we
	# restrict the version number to the first three dot-separated components for
	# comparison
	curl -sS https://api.github.com/repos/pyenv/pyenv/releases \
		| jq -r ".[0].tag_name" \
		| sed -E "s/v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/" 
}

checkUpdates() {
	[[ $(getInstalledVersion) != $(getLatestVersion) ]]
}

runUpdates() {
	PATH="$HOME/.pyenv/bin:$PATH" pyenv update 2>&1
}

postProcess() {
	local exitCode=2 # Will be turned to 0 if something was displayed
	if ! $SPM_DRY_RUN && [ "$MODULE_CHANGES" -gt 0 ]; then # If something changed 
		local warnIcon="${YELLOW}${WARN_ICON}${NORMAL}${WARN_ICON:+ }"
		echo -e "${warnIcon}Updated: make sure to source ~/.bashrc" 
		exitCode=0
	fi
	return $exitCode # Indicate nothing was displayed
}
