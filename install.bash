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
git clone https://github.com/romainv/sys-dependencies.git "$SPM_DIR"
# Run spm installation
"$SPM_DIR"/spm install spm
# Source .bashrc to make spm available in shell
source ~/.bashrc
