#!/bin/bash
# Installation of python

checkInstall() { 
	local latestVersion
	latestVersion=$(getLatestVersion)
	# We add pyenv's default location to ensure it is available, in case it was 
	# just installed or the current shell is not interactive
	PATH="$HOME/.pyenv/bin:$PATH" pyenv versions 2>&1 \
		| grep --quiet "^\s\?\*\?\s\?${latestVersion}" 2>&1
}

runInstall() {
	local latestVersion
	latestVersion=$(getLatestVersion)
	# Remove homebrew from PATH before launching install as this may lead to
	# broken python dependencies (e.g. _ctypes)
	PATH=$(
		echo "$HOME/.pyenv/bin:$PATH" \
		| sed -e 's|/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:||'
	) pyenv install "${latestVersion}" 2>&1
}

getInstalledVersion() { 
	PATH="$HOME/.pyenv/bin:$PATH" pyenv version-name 2>&1
}

getLatestVersion() {
	local version="$2"
	local versionFile
	if versionFile=$(cd "$PWD_BACKUP" && upsearch ".python-version"); then
		# If a version is configured in a .python-version file 
		cat "$versionFile"
	else
		# Otherwise, use the provided version
		echo "$version"
	fi
}

checkUpdates() {
	[[ $(getInstalledVersion "$@") != $(getLatestVersion "$@") ]]
}

runUpdates() {
	# The required version is installed, but is currently not the default
	PATH="$HOME/.pyenv/bin:$PATH" pyenv local "$(getLatestVersion)" 2>&1
}
