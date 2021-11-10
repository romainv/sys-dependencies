#!/bin/bash
# This file manages PPA repositories on Ubuntu

checkInstall() {
	local name="$1" 
	local files
	[ -f /etc/apt/sources.list ] \
		&& [ -d /etc/apt/sources.list.d ] \
		&& files=$(ls -qAH -- /etc/apt/sources.list.d) \
		&& [ -n "$files" ] \
		&& grep -q "^deb .*$name" /etc/apt/sources.list /etc/apt/sources.list.d/*
}

runInstall() {
	local name="$1" 
	sudo add-apt-repository -y "ppa:$name" 2>&1
	sudo apt-get update 2>&1
}

# No versioning of PPA
getInstalledVersion() { true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
