#!/bin/bash
# This installs spm on the local system, by cloning the repository into ~/.spm

# Check if git is installed
if [ ! -x "$(command -v "git")" ]; then
	# If git is not installed
	echo "Please install git first one your system."
	if [ -x "$(command -v apk)" ];       then 
		echo "You can do so by running: sudo apk add --no-cache git"
	elif [ -x "$(command -v apt-get)" ]; then 
		echo "You can do so by running: sudo apt-get install git"
	elif [ -x "$(command -v dnf)" ];     then 
		echo "You can do so by running: sudo dnf install git"
	elif [ -x "$(command -v zypper)" ];  then 
		echo "You can do so by running: sudo zypper install git"
	fi
	exit 1
fi

# Set SPM_DIR if needed
SPM_DIR=${SPM_DIR:-~/.spm}

# Clone spm repository
if [ ! -d "$SPM_DIR/.git" ]; then
	# If repository doesn't exist yet 
	git clone https://github.com/romainv/sys-dependencies.git "$SPM_DIR"
else
	# If repository was already cloned, update it
	git -C "$SPM_DIR" pull
fi

# Run spm installation (we use update to ensure each dependency and files are
# at the required version)
"$SPM_DIR"/spm update spm  

# Source .bashrc to make spm available in shell
# shellcheck source=/dev/null
source ~/.bashrc
