#!/bin/bash
# Installation of nvm, used to install and manage node

checkInstall() { 
	# nvm is not a command but a shell function
	[ -f "$HOME/.nvm/nvm.sh" ]
}

runInstall() {
	# Location of the latest install script on Github
	local url
	url="https://raw.githubusercontent.com/nvm-sh/nvm"
	url="$url/v$(getLatestVersion)/install.sh"
	unset NVM_DIR # This may be already set but creates conflicts
	curl -sS -o- "$url" 2>&1 | bash 2>&1 # Download and run installation script
	# Add bash completion to .bashrc
	# shellcheck disable=SC2016
	if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
  	addToFile \
  		'[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' \
  		~/.bashrc
		# shellcheck source=/dev/null
		source ~/.bashrc # Sets NVM_DIR in current environment
	fi
}

getInstalledVersion() { 
	# shellcheck source=/dev/null
	source "$HOME/.nvm/nvm.sh" &> /dev/null # Source nvm 
	nvm --version
}

getLatestVersion() { 
	# Retrieve releases info in JSON format, select the latest one, and remove 
	# any leading 'v'
	curl -sS https://api.github.com/repos/nvm-sh/nvm/releases \
		| jq -r ".[0].tag_name" \
		| sed -E "s/v(.*)/\1/"
}

checkUpdates() { 
	# Use != rather than < in case installed is not a number (e.g. 'master')
	[[ $(getInstalledVersion) != $(getLatestVersion) ]]
}

runUpdates() { 
	# Source: official github
	# shellcheck source=/dev/null
	(
	  cd "$HOME/.nvm" || exit 1 # Navigate to nvm install dir
	  git fetch --quiet --tags origin # Pull down the latest changes
		# Check out the latest version
	  git checkout --quiet "$(git describe \
	  	--abbrev=0 \
	  	--tags \
	  	--match "v[0-9]*" \
			"$(git rev-list --tags --max-count=1)")"
	) 
}
