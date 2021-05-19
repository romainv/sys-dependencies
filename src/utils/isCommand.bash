# Check if a command exists in path and is executable
isCommand() {
	if command -v "$1" &> /dev/null; then
		true
	else
		false
	fi
}
