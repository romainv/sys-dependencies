# Check if a command exists in path and is executable
isCommand() {
	if [ -x "$(command -v "$1")" ]; then
		true
	else
		false
	fi
}
