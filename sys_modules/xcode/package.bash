#!/bin/bash
# Installation of Command Line Tools for MacOS

checkInstall() {
	xcode-select -p > /dev/null  2>&1
	[ ! $? -eq 2 ]
}

runInstall() {
	xcode-select --install
}

getInstalledVersion() { 
	true
}

getLatestVersion() {
	true
}

checkUpdates() {
	false
}

runUpdates() {
	true
}
