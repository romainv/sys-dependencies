# Color definitions (source: https://stackoverflow.com/questions/4332478)
if [ -t 1 ] && [[ "$(tput 2>&1)" != "unknown terminal"* ]]; then
	# If stdout is a terminal
	ncolors=$(tput colors 2>/dev/null) # Retrieve the number of colors available
	if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
		# If colors are supported
		BLACK=$(tput setaf 0)
		export BLACK
		GREY=$(tput setaf 244)
		export GREY
		RED=$(tput setaf 1)
		export RED
		GREEN=$(tput setaf 2)
		export GREEN
		YELLOW=$(tput setaf 3)
		export YELLOW
		LIME_YELLOW=$(tput setaf 190)
		export LIME_YELLOW
		POWDER_BLUE=$(tput setaf 153)
		export POWDER_BLUE
		BLUE=$(tput setaf 4)
		export BLUE
		MAGENTA=$(tput setaf 5)
		export MAGENTA
		CYAN=$(tput setaf 6)
		export CYAN
		WHITE=$(tput setaf 7)
		export WHITE
		BOLD=$(tput bold)
		export BOLD
		NORMAL=$(tput sgr0)
		export NORMAL
		BLINK=$(tput blink)
		export BLINK
		REVERSE=$(tput smso)
		export REVERSE
		UNDERLINE=$(tput smul)
		export UNDERLINE
		ITALIC=$(tput sitm)
		export ITALIC
	fi
fi
