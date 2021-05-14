# Retrieve a copy of the supplied source file into the destination directory
# Arg 1 (sourceFile) The source file name (can be a URL or a command starting 
# with 'true && ')
# Arg 2 (targetFile) The target file
makeTempFile() {
	local sourceFile="$1"
	local targetFile="$2"
	local tmpDir
	tmpDir=$(mktemp -d) # Create a temporary directory to process the source file
	# Declared separately from assignment to allow retrieving exit codes
	local output 
	if [[ "$sourceFile" == http* ]]; then 
		# If source file is remote
		cd "$tmpDir" || exit 1 # Go to temp dir, which should be empty
		if ! output=$(wget -q "$sourceFile" 2>&1); then 
			# Download source file in temp dir
			echo "${RED}failed${NORMAL}"
			[ -n "$output" ] && echo "$output"
			rm -rf -- "$tmpDir" # Cleanup
			exit 1 # Exit if download failed
		else
			# Retrieve path from the only file in the temp dir
			local file
			for file in *; do sourceFile="$tmpDir/$file"; done 
		fi
		cd ~- || exit 1 # Go back to previous directory
	elif [[ "$sourceFile" == "true &&"* ]]; then 
		# If source file is a command
		local command="$sourceFile"
		sourceFile="$tmpDir/$(basename "$targetFile")" # Update source path
		# Run the command which will populate the file path
		if ! eval "$command" > "$tmpDir/command.log" 2>&1; then
			# If an error occurred while executing the command
			echo "${RED}failed${NORMAL}"
			cat "$tmpDir/command.log" # Display the logs that were captured
			rm -rf -- "$tmpDir" # Cleanup
			exit 1 # Make sure script execution stops here
		fi
	else # If source file is local
		local sourcePath="$PARENT_MODULE_DIR" # Determine the file's source path
		# Path to the temp file (keep only filename from source)
		local tmpFile="$tmpDir/${sourceFile##*/}" 
		# Copy file from source dir to temp dir
		if ! output=$(override \
				"$(rel2abs "$sourceFile" "$sourcePath")" \
				"$tmpFile"); then 
			echo "${RED}failed${NORMAL}"
			[ -n "$output" ] && echo "$output"
			rm -rf -- "$tmpDir" # Cleanup
			exit 1 # Exit if download failed
		else
			sourceFile="$tmpFile" # Update source path
		fi
	fi
	echo "$sourceFile" # Return the temp file path
}
