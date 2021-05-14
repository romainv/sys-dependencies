# Defines icons
if charmap=$(locale charmap 2>/dev/null) && [[ "$charmap" == "UTF-8" ]]; then
	# If current terminal supports unicode characters
	export SUCCESS_ICON="\uf42e"
	export WARN_ICON="\uf071"
	export INFO_ICON="\uf05a"
	export DOT_ICON="\u2022"
fi
