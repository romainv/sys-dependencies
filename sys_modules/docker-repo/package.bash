#!/bin/bash
# Installation of the docker repository required to install docker

checkInstall() { 
	[ -f /etc/apt/sources.list.d/docker.list ]
}

runInstall() {
	# Add Docker’s official GPG key
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
		| sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	# Setup the stable repository
	printf "deb [arch=%s signed-by=%s] %s %s %s" \
		"$(dpkg --print-architecture)" \
		"/usr/share/keyrings/docker-archive-keyring.gpg" \
		"https://download.docker.com/linux/ubuntu" \
		"$(lsb_release -cs)" \
		"stable" \
		| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	# Refresh apt
	sudo apt-get update 2>&1
}

# No versioning
getInstalledVersion() { true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
