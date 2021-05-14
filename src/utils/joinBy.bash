# Join values by supplied delimiter
# Usage: joinBy , a b c # a,b,c
# Usage with an array: FOO=( a b c ); joinBy , "${FOO[@]}" # a,b,c
# Source: https://stackoverflow.com/questions/1527049
# Arg1: the delimiter
# Arg*: the values
# Return: the string with array's values separated by the delimiter
joinBy() {
	local d=$1 
	shift
	echo -n "$1"
	shift
	printf "%s" "${@/#/$d}"
}
