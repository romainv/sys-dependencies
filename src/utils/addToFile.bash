# Add a line to a file only if it doesn't already exist
# Useful to add configuration to .bashrc for instance
# Arg $1: the line to add
# Arg $2: the file on which to append the line
# Arg $3: if 'true', will only check if an update is required and not perform it
addToFile() {
	local line="$1"
	local file="$2"
	if [[ "$#" -gt 2 && "$3" == "true" ]]; then
		local checkOnly=true
	else
		local checkOnly=false
	fi
	if [ -f "$file" ] && grep -qF "$line" "$file"; then 
		# If line already exists in file, indicate no update was performed
		false 
	elif $checkOnly; then # If line doesn't exist in file and we only check
		true # Indicate an update is required
	else # If line doesn't exist in file and we actually want to add it
		if echo -e "$line" >> "$file"; then true # Indicate update was successful
		else false; fi # Indicate update failed
	fi
}
