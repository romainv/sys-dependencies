# This file contains shortcuts to move the cursor in terminal
# Usage: echo -e "${SHORTCUT}" or printf "${SHORTCUT}"

# Move cursor to beginning of line
export LINE_START="\r" 

if [ -t 1 ]; then
	# If stdout is a terminal 
	# Indicate stdout is initially a terminal, as we won't be able to check 
	# later on (e.g. in functions that would capture stdout)
	export IS_TERMINAL="true"
	# Move the cursor up one line
	export PREVIOUS_LINE="\033[1A" 
	# Back to beginning of previous line
	export PREVIOUS_LINE_START="${PREVIOUS_LINE}${LINE_START}" 
	# Erase the current line's content
	export CLEAR_LINE="\033[K" 
	# Shortcut to both commands
	export CLEAR_PREVIOUS_LINE="${PREVIOUS_LINE_START}${CLEAR_LINE}" 
	# Disable line wrap
	export NO_WRAP="\033[?7l" 
	# Enable line wrap
	export WRAP="\033[?7h" 
fi
