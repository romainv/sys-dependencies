# Override file $2 with file $1 if necessary
# Arg $1: the source. If it's a folder, all its files will override those in 
# destination
# Arg $2: the destination. It should be of same nature as source, i.e. if $1 is
# a file, $2 should too
# Arg $3: 'true' if we should check only and not actually override
# Returns: true if file was copied, 2 otherwise
override() {
	# Retrieve arguments
	local sourcePath="$1"
	local destPath="$2"
	local checkOnly=${3:-false}
	# Process override
	if [ ! -f "$sourcePath" ] && [ ! -d "$sourcePath" ]; then 
		# If source file cannot be found
		echo "skipped '$destPath': '$sourcePath' not found"
		return 2 # Indicate no changes were made
	elif [ -d "$sourcePath" ]; then 
		# If source exists and is a folder
		echo "" # Skip a line for better display
		local changes=0 # Keep track of changes made in the folder
		for f in "$sourcePath"/[a-zA-Z0-9]* ; do
			# Loop through all files in dir starting with a letter or number
			# Run the function with specific files assuming $destPath is a folder
			override "$f" "$destPath/$(basename "$f")" "$checkOnly" \
				&& changes=$((changes+1)) # Increment changes if needed
		done
		# Indicate whether changes were made or not
		if [ $changes -gt 0 ]; then
			true
		else
			return 2 
		fi
	elif [ ! -f "$destPath" ] || ! cmp -s "$sourcePath" "$destPath"; then
		# If source is an existing file and target doesn't exist or is different 
		# than source 
		# Be accurate on whether destination was overrided or copied 
		local operation
		if [ ! -f "$destPath" ]; then
			operation="copied"
		else
			operation="overrided"
		fi
		if $checkOnly; then 
			# If we're only checking for changes
			echo "$operation '$destPath' (check only)"
			true # Indicate changes are required
		# At this stage, we proceed with the override. First we try without sudo:
		else
			# Create destination directory if it doesn't exist
			mkdir -p "$(dirname "$destPath")" 
			if yes 2>/dev/null \
				| cp -rf --remove-destination "$sourcePath" "$destPath" \
				2>/dev/null; then 
				# We mute yes as it raises (harmless) warnings if the function is 
				# called inside $()
				echo "$operation '$destPath'" # Override was successful without sudo
				true # Indicate changes were made
			else # Use sudo if required	
				local result
				if result=$(yes 2>/dev/null \
					| sudo cp \
						-rf \
						--remove-destination \
						"$sourcePath" "$destPath" 2>&1); then # Override
					echo "$operation '$destPath' with sudo" # Override was successful 
					true # Indicate changes were made or are required
				else
					echo "$result"
					return 1 # Indicate failure
				fi
			fi
		fi
	else # Target file already up to date
		echo "skipped '$destPath': no change"
		return 2 # Indicate no changes were made
	fi
}
