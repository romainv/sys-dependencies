#!/bin/bash
# This file provides a template to manage dependencies that are available in 
# the Ruby package manager

checkInstall() {
	local name="$1" 
	local isInstalled
	isInstalled=$(gem list -i "^${name}$" 2>&1)
	[[ "$isInstalled" == "true" ]]
}

runInstall() {
	local name="$1" 
	sudo env PATH="$PATH" gem install -q "$name"
}

getInstalledVersion() {
	local name="$1"
	# Retrieve highest version installed (there could be many). Note it may not 
	# be set to default
	gem list "^${name}$" | grep -Po '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

getLatestVersion() {
	local name="$1"
	# Retrieve highest remote version
	gem list "^${name}$" --remote --all \
		| grep -Po '[0-9]+\.[0-9]+\.[0-9]+' \
		| head -n 1
}

checkUpdates() {
	local name="$1" 
	# Exact name matching by adding a trailing space
	gem outdated 2>&1 | grep --quiet "^$name " 
}

runUpdates() {
	local name="$1" 
	sudo env PATH="$PATH" gem update -q "$name"
}
