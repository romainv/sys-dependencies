# Repace all occurrences of a parameter in format ${PARAM_NAME} by its value in
# the supplied file
# Usage 1: Replace in file, e.g. replaceParameters "$filePath"
# 	Arg 2 (file) The file in which to replace
# Usage 2: Replace in pipe, e.g. echo "text" | replaceParameters
replaceParameters() {
	local file="$1"
	# Build the sed command to replace all parameters
	local sedCommands=()
	local paramName
	for paramName in "${!SPM_PARAMS[@]}"; do
		local paramValue
		paramValue=${SPM_PARAMS[$paramName]} 
		sedCommands+=( "s/\\\${${paramName}}/${paramValue//\//\\\/}/g" )
	done
	local sedCommand
	sedCommand=$(joinBy ";" "${sedCommands[@]}") # Separate commands by semicolon
	# Execute the 
	if [[ -n "$file" ]]; then
		# If a file is specified
		# Replace all occurences of ${param} in file (need to escape slashes)
		sed -i -e "$sedCommand" "$file"
	else
		# If pipe should be replaced
		sed -e "$sedCommand"
	fi
}
