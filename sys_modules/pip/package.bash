#!/bin/bash
# This installs and updates pip packages. The pip version used is based on
# pyenv's config

checkInstall() {
	local name="$1"
	runPip3 list 2>&1 | grep --quiet "^$name "
}

runInstall() {
	local name="$1"
	runPip3 -q install "$name" 2>&1 # global install
	runPip3 -q install --user "$name" 2>&1 # local install
}

getInstalledVersion() {
	local name="$1"
	runPip3 list 2>&1 \
		| grep "^$name " \
		| grep -Poi '[0-9][0-9.-a-z]+' 
}

getLatestVersion() {
	local name="$1"
	runPip3 install "$name==" 2>&1 \
		| grep -Poi '\(.*\)' \
		| grep -Poi '[0-9][0-9.-a-z]+' \
		| tail -n 1
}

checkUpdates() {
	local name="$1"
	runPip3 list --outdated 2>&1 | grep --quiet "^$name "
}

runUpdates() {
	local name="$1"
	runPip3 -q install --upgrade "$name" 2>&1 # global install
	runPip3 -q install --upgrade --user "$name" 2>&1 # local install
}

# Util function to run the version of pip managed by pyenv
runPip3() {
	local args
	args=("$@") # Capture arguments
	# Make sure pyenv is in path, and use it to locate the right version of pip
	$(PATH="$HOME/.pyenv/bin:$PATH" pyenv which pip3) "${args[@]}" 
}
