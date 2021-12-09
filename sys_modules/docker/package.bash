#!/bin/bash
# Post-installation steps of Docker

checkInstall() { 
	# Check if docker group exists and contains user
	grep -e "docker:" /etc/group | grep -qe "$USER"
}

runInstall() {
	# Create the docker group if it doesn't already exist
	if ! grep -qe "docker:" /etc/group; then
		sudo groupadd docker 	
	fi
	# Add current user to the group
	sudo usermod -aG docker "$USER" 
	# Activate the changes to the group
	newgrp docker 
}

# No versioning
getInstalledVersion() { true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
