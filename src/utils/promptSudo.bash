# Prompt for user's root password if required
promptSudo() {
	if ! isCommand sudo; then
		# If sudo is not available in the current environment
		return 0
	elif sudo -n true 2>/dev/null; then 
		# If user already has permissions to execute as sudo
		return 0 # Proceed
	else # If user needs to enter sudo password
		# Empty command that will trigger password prompt, or fail if not provided
		sudo true && return 0 || return 1
	fi
}
