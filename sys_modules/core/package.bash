#!/bin/bash
# Install and configure the core dependencies required to run spm
# The initial install cannot rely on package.json as we cannot read it without
# jq. Once the initial dependencies are installed, we switch to package.json to
# manage the dependencies

checkInstall() {
	isCommand jq \
		&& isCommand curl \
		&& ( [[ "$CURRENT_OS" != "MACOS" ]] || isCommand brew )
}

runInstall() {
	# As jq is a core dependency, we cannot use the package.json at this stage
	if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
		# Install jq
		! isCommand jq && sudo apt-get install -y jq 2>&1
		# Install curl
		! isCommand curl && sudo apt-get install -y curl 2>&1
	elif [[ "$CURRENT_OS" == "MACOS" ]]; then
		# Install brew, which is required to install jq
		if ! isCommand jq && ! isCommand brew; then
			# shellcheck source=/dev/null
			source <(curl -fsSL \
				https://raw.githubusercontent.com/Homebrew/install/master/install.sh) \
				2>&1
		fi
		# Install jq
		! isCommand jq && brew install jq
		# curl comes pre-installed with macos
	else
		echo "Installation of core dependencies is not supported on your system"
		exit 1
	fi
}

getInstalledVersion() {	true; }
getLatestVersion() { true; }
checkUpdates() { false; }
runUpdates() { true; }
