#!/bin/bash
# Install and update AWS CLI

checkInstall() {
	isCommand aws
}

runInstall() {
	local tmpDir
	tmpDir=$(mktemp -d) # Create a temporary directory
	cd "$tmpDir" || return 1 # Move to temporary directory
	if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
		curl -sS https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
			-o awscliv2.zip 2>&1
		unzip awscliv2.zip 2>&1
		sudo ./aws/install 2>&1
	elif [[ "$CURRENT_OS" == "MACOS" ]]; then
		curl -sS https://awscli.amazonaws.com/AWSCLIV2.pkg -o AWSCLIV2.pkg 2>&1
		sudo installer -pkg AWSCLIV2.pkg -target / 2>&1
	else
		echo "OS not supported"
		return 1
	fi
	# Activate command completion
	addToFile "complete -C '$(which aws_completer)' aws" ~/.bashrc
	rm -rf -- "$tmpDir" # Clean-up
}

getInstalledVersion() {
	aws --version 2>&1 | sed -E "s/aws-cli\/([0-9.]+) .*/\\1/g"
} 

getLatestVersion() {
	curl -sS https://api.github.com/repos/aws/aws-cli/tags \
		| jq -r ".[0].name"
}

checkUpdates() {
	[[ $(getInstalledVersion) != $(getLatestVersion) ]]
}

runUpdates() {
	if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
		# Download the installer
		local tmpDir
		tmpDir=$(mktemp -d) # Create a temporary directory
		cd "$tmpDir" || return 1 # Move to temporary directory
		curl -sS https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
			-o awscliv2.zip 2>&1
		unzip awscliv2.zip 2>&1
		# Retrieve the binary directory
		local binDir
		if ! binDir=$(dirname "$(which aws)"); then
			# If an error occured 
			echo "Failed to retrieve bin dir: $binDir"
			return 1
		fi
		# Retrieve the installation directory
		local installDir
		# shellcheck disable=SC2012
		if ! installDir=$(ls -l "$(which aws)" \
			| sed -E "s/.* -> (.+)\/v.*/\\1/g"); then
			# If an error occured 
			echo "Failed to retrieve install dir: $installDir"
			return 1
		fi
		# Run the installer with the right arguments
		sudo ./aws/install \
			--bin-dir "$binDir" \
			--install-dir "$installDir" \
			--update 2>&1
	elif [[ "$CURRENT_OS" == "MACOS" ]]; then
		runInstall # Same steps
	else
		echo "OS not supported"
		return 1
	fi
} 
