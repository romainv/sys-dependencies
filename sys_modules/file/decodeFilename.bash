# Decode special characters in a filename
decodeFilename() {
	local filename="$1"
	# Replace special <rcfile> by the appropriate shell rc file
	if [[ "$CURRENT_OS" == "MACOS" ]]; then
		filename="${filename/<rcfile>/~/.zshrc}"
	else
		filename="${filename/<rcfile>/~/.bashrc}"
	fi
	# Expand ~ to home directory for target file
	filename="${filename/#\~/$HOME}"
	# Return the decoded filename
	echo "$filename"
}
