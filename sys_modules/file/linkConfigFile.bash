# Create a symlink between a source file and a target file
# Arg 1 (sourceFile): The path targetFile should link to (relative to 
# targetFile's directory)
# Arg 2 (targetFile): The path to target file (relative to current working dir)
# Arg 3 (checkOnly - optional) "true" to perform a check and no changes
linkConfigFile() {
	local sourceFile="$1"
	local targetFile="$2"
	local checkOnly="$3"
	if test -h "$targetFile" \
		&& [[ $(readlink -f "$targetFile") \
			-ef $(rel2abs "$sourceFile" "$targetFile") ]]; then
		# If target is already a symlink pointing to the source
		return 2 # Indicate no changes are required
	elif [[ "$checkOnly" == "true" ]]; then 
		# If target doesn't point to source, and we're in dry-run mode
		true # Indicate changes are required
	else # If target doesn't point to source, and we're not in dry-run mode
		local result="" 
		if result=$(ln -s -f "$sourceFile" "$targetFile" 2>&1); then
			# Create the link
			true # Indicate changes were made
		else # If an error occurred
			[ -n "$result" ] && echo "$result" # Display error
			return 1
		fi
	fi
}
