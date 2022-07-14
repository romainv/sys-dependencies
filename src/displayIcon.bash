# Display custom icons depending on the dependency type
# Arg 1 (moduleType) The module id
# Arg 2 (suffix) A suffix to append to the icon, if the icon can be displayed
displayIcon() {
	local moduleType="$1"
	local suffix="$2"
	local charmap
	if [ -n "${IS_TERMINAL-}" ] \
		&& charmap=$(locale charmap 2>/dev/null) \
		&& [[ "$charmap" == "UTF-8" ]]; then
		# If terminal supports unicode characters
		local icon="" # Will contain the icon to display
		case $moduleType in
			apt) icon="\ue77d" ;; # Debian logo
			awscli) icon="\ue795" ;; # Terminal logo
			gem) icon="\ue23e" ;; # A gem
			pip|pipenv|pyenv|python) icon="\ue73c" ;; # Python logo
			npm) icon="\ue71e" ;; # npm logo
			certificate) icon="\uf023" ;; # A lock
			snap) icon="\ue75e" ;; # Snap logo
			node) icon="\ue718" ;; # Node logo
			parameter) icon="\ue615" ;; # Setting
			os)
				case "$CURRENT_OS" in
					SOLARIS) 	icon="\uf185" ;; # A sun
					MACOS)		icon="\ue711" ;; # Apple
					UBUNTU) 	icon="\ue73a" ;; # Ubuntu icon
					LINUX) 		icon="\ue712" ;; # Default Linux icon
					BSD)     	icon="\uf30c" ;; # BSD
					WINDOWS)  icon="\ue70f" ;; # Windows
					*)        icon="\uf128" ;; # A question mark
				esac ;;
			file) icon="\uf15c" ;; # Config file
			repo) icon="\ue725" ;; # Git branch
			vim) icon="\ue7c5" ;; # Vim logo (v + im)
			vim-plug|plug) icon="\ue62b" ;; # Vim logo (just v)
			brew) icon="\uf0fc" ;; # Beer glass
			brotli) icon="\uf1c6" ;; # Zipped archive
			*) icon="\ue735" ;; # Package
		esac
		printf "%s%s" "${icon@E}" "$suffix" # Convert the unicode to the actual icon
	fi
}
