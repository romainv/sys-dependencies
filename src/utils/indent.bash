# Indent some text to be displayed
# Usage 1: printf "test" | indent 2 "-" 
# 	=> outputs '----test'
# Usage 2: indentation=$(echo "" | indent 2) && printf "${indentation}test" 
# 	=> outputs '  test'
# Arg 1 (indentation - optional): The number of characters to display
# Arg 2 (character - optional): The character to repeat
indent() {
	local indentation=${1:-0} # 0 by default
	local character="${2:- }" # Space by default
	if [[ $indentation -gt 0 ]]; then
		# Repeat supplied characters by supplied amount of times
		local repeats
		repeats=($(eval "echo {1.."$((indentation))"}"))
		local characters
		characters=$(printf "%.0s${character}" "${repeats[@]}")
		# Replace each line start and carriage return with the indentation
		sed -Eu "s/(^|\\r)/\1$characters/g" # -u for unbuffered to not delay output
	else
		cat # This simply passes through stdin to stdout
	fi
}
