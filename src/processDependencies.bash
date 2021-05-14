# List of OS names
declare -a OS_LIST=(\
	UBUNTU \
	MACOS \
	EC2 \
	SOLARIS \
	LINUX \
	BSD \
	WINDOWS)

# Process a module's dependencies
# Arg 1 (dependencies) The dependencies description in JSON format
processDependencies() {
	local dependencies="$1"
	local changes=0 # Keep track of changes in module's dependencies
	local dependency 
	# Keep track of current module dir to indicate where local files are rooted
	PARENT_MODULE_DIR="$MODULE_DIR" 
	export PARENT_MODULE_DIR
	# We use -r to have each entry on new lines, and base64 to escape newlines 
	# within entries
	for dependency in $(jq -r "to_entries | .[] | @base64" \
		<<< "${dependencies}"); do 
		dependency=$(echo "${dependency}" | base64 --decode) # Decode base64
		local depId # Module id of the current dependency
		depId=$(jq -j ".key" <<< "${dependency}") 
		local depValue # Value associated with the dependency id
		depValue=$(jq -j ".value" <<< "${dependency}")
		if [[ "$depId" == "param/"* ]]; then
			# If current dependency is a parameter
			# FIXME: Parameters won't be available to the current module as
			# processDependencies runs in a subshell. It will only be available in
			# other dependencies
			# Extract the parameter name in 'param/<name>'
			processParameter "${depId#*/}" "$depValue" \
				&& changes=$((changes+1)) # Increment changes if any
		elif elementIn "$depId" "${OS_LIST[@]}"; then
			# If current dependency specifies an OS
			# Check if dependency should be processed
			local targetOS="$depId" # Retrieve OS required by dependency
			if [[ "$targetOS" != "$CURRENT_OS" ]]; then
				# If target OS is not the current one
				continue # Skip dependency if we're not on target OS
			else
				# If target OS matches the current one, process the dependencies
				# specified under the OS entry, in a subshell
				(processDependencies "$depValue")
				local depStatus=$?
				# Propagate request to terminate parent shells
				[ $depStatus -eq 1 ] && exit 1 
				# Indicate there were no changes
				[ ! $depStatus -eq 0 ] && changes=$((changes+1)) 
			fi
		else # If dependency is not an OS
			# Recursively process module
			processModule "$depId" "$depValue" \
				&& changes=$((changes+1)) # Increment changes if any
		fi
	done
	# Indicate whether there have been changes
	if [ "$changes" -gt 0 ]; then
		# We return 2 if changes have been made to differenciate failures (exit 1) 
		# from no changes
		exit 2
	else
		exit 0
	fi
}
