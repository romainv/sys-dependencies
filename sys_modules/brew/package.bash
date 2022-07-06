#!/bin/bash
# Install and update brew and packages

preProcess() {
	local name="$1"
	# Add 'brew' as a dependency if a specific brew package is provided (not for
	# brew itself otherwise we'd enter an infinite loop)
	[[ "$name" != "brew" ]] \
		&& dependencies=$(jq -j ". += {\"brew\": \"*\"}" \
			<<< "${dependencies}" 2>&1)
	return 2 # Indicate nothing was changed or displayed
}

checkInstall() {
	local name="$1"
	if [[ "$name" == "brew" ]]; then # brew itself, not one of its packages
		# Make sure brew is in PATH if we just installed it
		PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}" isCommand brew
	else # A brew package
		runBrew list "$name" 2>&1
	fi
}

runInstall() {
	local name="$1"
	local version="$2"
	if [[ "$name" == "brew" ]]; then # brew itself
		if [ -f /.dockerenv ]; then
			# If we're on Docker with the root user, we need to create a new user and 
			# install brew as this user
			local preInstall
			if ! preInstall=$(
				apt-get install ruby-full locales --no-install-recommends -y 2>&1	\
					&& rm -rf /var/lib/apt/lists/*
				localedef -i en_US -f UTF-8 en_US.UTF-8
				useradd -m -s /bin/bash linuxbrew && \
					echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
			); then
				printf "Pre-install failed: %s\n" "$preInstall"
				return 1
			fi
			# Download the install script
			local installScript
			installScript=$(curl -fsSL \
				https://raw.githubusercontent.com/Homebrew/install/master/install.sh)
			# If we're currenly logged in as root
			sudo -H -u linuxbrew bash -c "$installScript" 2>&1
		else # If we're not on Docker
			# We use echo to simulate pressing ENTER
			# shellcheck source=/dev/null
			echo | source <(curl -fsSL \
				https://raw.githubusercontent.com/Homebrew/install/master/install.sh) \
				2>&1
		fi
		if [[ "$CURRENT_OS" == "UBUNTU" ]]; then
			# Add to path (not necessary on MACOS)
			local brewHome="/home/linuxbrew/.linuxbrew"
			local exports
			if id "linuxbrew" &>/dev/null; then
				# If user linuxbrew exists
				exports=$(cd "$brewHome" \
					&& sudo -H -u linuxbrew "$brewHome"/bin/brew shellenv)
			else
				exports=$(cd "$brewHome" && "$brewHome"/bin/brew shellenv)
			fi
			test -d "$brewHome" && eval "$exports"
			addToFile "$exports" ~/.bashrc
			# shellcheck source=/dev/null
			source ~/.bashrc
		fi
	else # A brew package
		if [[ -n "$version" && "$version" != "*" ]]; then
			# If a version was specified
			runBrew install "$name" "$version" 2>&1
		else # If no version was specified
			runBrew install "$name" 2>&1
		fi
	fi
}

getInstalledVersion() {
	local name="$1"
	if [[ "$name" == "brew" ]]; then
		runBrew --version 2>&1 | head -n 1 | sed -E "s/Homebrew (.*)$/\1/g"
	else # A specific brew module
		runBrew info "$name" 2>&1 \
			| head -n 1 \
			| sed -E "s/^${name}:.*[[:blank:]]+([0-9.]+)[[:blank:]]+\\(bottled\\).*/\\1/g"
	fi
}

getLatestVersion() { 
	local name="$1"
	if [[ "$name" == "brew" ]]; then # brew itself
		curl -sS https://api.github.com/repos/Homebrew/brew/releases \
			| jq -r ".[0].name"
	else # A brew package
		# Capture the most recent version from brew outdated's output
		# We need to use --verbose as brew won't display versions in a
		# non-interactive shell by default
		runBrew outdated --verbose "$name" 2>&1 \
			| sed -E "s/^${name}[[:blank:]]+.*<[[:blank:]]+([0-9.]+).*$/\\1/g"
	fi
}

checkUpdates() {
	local name="$1"
	if [[ "$name" == "brew" ]]; then # brew itself
		[[ $(getInstalledVersion "$name") != $(getLatestVersion "$name") ]]
	else # A brew package
		runBrew outdated --verbose "$name" 2>&1 \
			| grep --quiet "^${name}[[:blank:]]"
	fi
}

runUpdates() {
	local name="$1"
	if [[ "$name" == "brew" ]]; then # brew itself
		runBrew update 2>&1
	else # A brew package
		runBrew upgrade "$name" 2>&1
	fi
}

# Util function to run brew as a user since running as root is not supported
runBrew() {
	local args
	args=("$@") # Capture arguments
	local brewHome="/home/linuxbrew"
	if [[ $EUID -eq 0 ]]; then
		# If current user is root
		# Move to brew's home otherwise brew complains the current pwd doesn't exist
		cd "$brewHome" || return 1
		# Run brew as a user
		sudo -H -u linuxbrew "$brewHome"/.linuxbrew/bin/brew "${args[@]}"
	else # If we're already logged as a user
		"$brewHome"/.linuxbrew/bin/brew "${args[@]}"
	fi
}
