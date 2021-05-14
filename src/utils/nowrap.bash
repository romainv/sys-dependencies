# Disable line wrapping
# Usage: printf "Something very long" | nowrap
nowrap() {
	# The basic implementation would be:
	# 	cat <(printf "${NO_WRAP}") - <(printf "${WRAP}") 
	# which would wrap stdin into wrapping / unwrapping codes.
	# The challenge with this implementation is that the trailing wrap code is 
	# appended on a new line in case we use echo, and this creates issues when 
	# used together with | indent:
	# 	echo "Some long text" | nowrap | indent 2
	# The above displays extra spaces below "Some long text".
	# The below implementation thus reads stdin line by line to display the wrap 
	# code before the line breaks, while still processing inputs that don't end 
	# with a line break.
	# We need to set 'IFS= ' to capture trailing and leading spaces, as specified 
	# here: https://stackoverflow.com/questions/29689172
	
	# Process each line ending with a line break
	local line
	while IFS= read -r line; do
		printf "${NO_WRAP}%b${WRAP}\n" "$line" # Add a new line after wrap code
	done
	# Process the last (or only) line in case it doesn't end with a line break
	# This case happens when read finds end-of-file before line break, in which 
	# case it fails and the previous loop doesn't run. $line still contains 
	# content up to end-of-file
	if [ -n "$line" ]; then
		printf "${NO_WRAP}%b${WRAP}" "$line" # Don't add a new line
	fi
}
