#!/bin/bash
# This file provides a template to manage dependencies that are available in 
# the apt package manager

checkInstall() {
	local name="$1" 
	# Exact name matching is ensured by passing $name to dpkg
	DEBIAN_FRONTEND=noninteractive dpkg --get-selections "$name" 2>&1 \
		| grep --quiet "^$name" 
}

runInstall() {
	local name="$1" 
	DEBIAN_FRONTEND=noninteractive sudo apt-get install -y "$name" 2>&1
}

getInstalledVersion() {
	local name="$1"
	apt-cache policy "$name" 2>&1 | sed -n -e 's/^.*Installed: //p'
}

getLatestVersion() {
	local name="$1"
	apt-cache policy "$name" 2>&1 | sed -n -e 's/^.*Candidate: //p'
}

checkUpdates() {
	local name="$1" 
	apt-get -s upgrade "$name" 2>&1 | grep '^Conf\|Inst' | grep --quiet " $name "
}

runUpdates() {
	local name="$1" 
	DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y "$name" 2>&1
}
