#!/bin/bash
# This file provides a template to manage global npm packages
# It doesn't handle local packages, as these are defined in package.json 

checkInstall() {
	local name="$1" 
	# Check if package is installed globally
	npm list --depth 1 --location=global "$name" > /dev/null 2>&1 
}

runInstall() {
	local name="$1" 
	npm install --location=global "$name" 2>&1
}

getInstalledVersion() {
	local name="$1"
	# Extract version number
	npm ls --location=global --depth=0 "$name" 2>&1 \
		| sed -nE "s/.*${name}@([0-9.]+).*/\1/p" 
}

getLatestVersion() {
	local name="$1"
	# Extract latest version for supplied package name (last version listed by 
	# npm outdated)
	# This will only return a value if package is outdated
	npm outdated --location=global --parseable --depth=0 "$name" 2>&1 \
		| sed -nE "s/.*:${name}@([0-9.]+)$/\1/p" 
}

checkUpdates() {
	local name="$1" 
	# Check if package name is listed as outdated
	npm outdated --location=global --parseable --depth=0 "$name" 2>&1 \
		| grep --quiet "$name"
}

runUpdates() {
	local name="$1" 
	npm install --location=global "$name" 2>&1
}
