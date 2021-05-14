# Recursively find the supplied file from the current working directory
# Example usage (retrieve the npm package root):
# 	root=$(dirname -- "$(upsearch 'package.json')") 
# Arg 1 (pattern): Pattern to search for 
upsearch() {
	local pattern="$1"
	if test -e "$pattern"; then
		# If pattern exists in current directory
  	echo "$PWD/$pattern" # Display it so it can be captured
  	return # Return 0 to indicate we found something
	elif test / == "$PWD"; then
  	# If we've reached the root of the filesystem
  	return 1 # Indicate we haven't found the pattern
	else
		# If there are more parent directories to search
  	local result code
  	# Run the next recursion in a subshell to note mess up with current pwd 
  	result=$(cd .. && upsearch "$pattern")
		code=$?
		echo "$result" # Display result if we found any
		return $code # Forward the return code
	fi
}
