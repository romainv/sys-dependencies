#!/bin/bash
# This installs and updates pip packages

checkInstall() {
	local name="$1"
	pip3 list 2>&1 | grep --quiet "^$name "
}

runInstall() {
	local name="$1"
	pip3 -q install "$name" 2>&1 # global install
	pip3 -q install --user "$name" 2>&1 # local install
}

getInstalledVersion() {
	local name="$1"
	pip3 list 2>&1 \
		| grep "^$name " \
		| grep -Poi '[0-9][0-9.-a-z]+' 
}

getLatestVersion() {
	local name="$1"
	pip3 install "$name==" 2>&1 \
		| grep -Poi '\(.*\)' \
		| grep -Poi '[0-9][0-9.-a-z]+' \
		| tail -n 1
}

checkUpdates() {
	local name="$1"
	pip3 list --outdated 2>&1 | grep --quiet "^$name "
}

runUpdates() {
	local name="$1"
	pip3 -q install --upgrade "$name" 2>&1 # global install
	pip3 -q install --upgrade --user "$name" 2>&1 # local install
}
