#!/bin/bash
# This file manages PPA repositories on Ubuntu

checkInstall() {
	local name="$1" 
	[ -f /etc/apt/sources.list ] \
		&& [ -d /etc/apt/sources.list.d ] \
		&& grep -q "^deb .*$name" /etc/apt/sources.list /etc/apt/sources.list.d/*
}

runInstall() {
	local name="$1" 
	sudo add-apt-repository "ppa:$name" 2>&1
	sudo apt-get update 2>&1
}

# No versioning of PPA
getInstalledVersion() { true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
