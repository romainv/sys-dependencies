#!/bin/bash
# Install and configure snap packages 

checkInstall() {
	local name="$1"
	# Exact name matching is ensured by passing $name to snap 
	snap list "$name" 2>&1 | grep --quiet "^$name" 
}

runInstall() {
	local name="$1"
	sudo snap install --classic "$name" 2>&1
}

getInstalledVersion() {
	local name="$1"
	# Remove leading v if any
	snap list "$name" 2>&1 \
		| sed -nE "s/^$name[[:blank:]]+v?([0-9.a-z+-]+).*/\\1/p"
}

getLatestVersion() {
	local name="$1"
	# Capture the first version number under the channels section
	snap info --verbose "$name" 2>&1 \
		| sed -n -E -e '/^channels:.*/,$ {
				# Matches lines below "channel:" (included)
				/^.*:[[:blank:]]+v?([0-9.a-z+-]+).*$/ {
					s//\1/ # Extract the version number (remove leading v if any)
					p # Print the version
					q0 # Exit to only extract the first version number
				}
			}'
}

checkUpdates() {
	local name="$1"
	# Snaps are updated in the background every day, so this is likely not useful
	snap refresh --list 2>&1 | grep --quiet "^$name " 
}

runUpdates() {
	local name="$1"
	sudo snap refresh "$name" 2>&1
}
