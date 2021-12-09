#!/bin/bash
# Installation of the docker repository required to install docker

checkInstall() { 
	# Assume the repository was already setup if Docker is installed
	isCommand docker
}

runInstall() {
	# Add Docker’s official GPG key
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
		| sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	# Setup the stable repository
	echo \
		"deb [arch=$(dpkg --print-architecture) \
		signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
		https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
		| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# No versioning
getInstalledVersion() { true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
