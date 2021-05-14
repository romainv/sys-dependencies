# Check if a string is in a list
# Source: https://stackoverflow.com/questions/3685970
# Arg 1: The string to search for
# Arg 2+ (optional): The list of elements to search in. If omitted, will 
# attempt to read stdin
# Usages:
# 	elementIn "element" "${array[@]}"
# 	elementIn "element" < file.txt
elementIn() {
  local e match="$1"
  shift # Remove $1 from arguments list
  if [ $# -eq 0 ]; then # If list to search in was not passed as arguments 
  	while read -r e; do # Loop through each line in stdin
			# Stop searching as soon as we found a match
  		[[ "$e" == "$match" ]] && return 0 
  	done 
  else # If list to search in was passed as arguments
  	for e; do # Loop through each argument
			# Stop searching as soon as we found a match
  		[[ "$e" == "$match" ]] && return 0 
  	done 
  fi
	# If we reach here, no match was found and thus we return an error code
  return 1 
}
