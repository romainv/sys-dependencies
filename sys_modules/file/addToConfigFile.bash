# This function appends lines to a config file if necessary
# Arg 1 (targetFile): The file to update
# Arg 2 (checkOnly - optional) "true" to perform a check and no changes
# Lines to add are read from stdin and should be supplied in base64 encoding
addToConfigFile() {
	local targetFile="$1"
	local checkOnly="$2"
	local content # Contains the content of stdin
	local updated=false # Updated indicates whether any changes were performed
	while read -r content; do
		content=$(echo "$content" \
			| base64 --decode \
			| replaceParameters) # Decode base64 then replace params
		# Append line if necessary
		addToFile "$content" "$targetFile" "$checkOnly" \
			&& updated=true
	done
	# Indicate if file was updated or update is needed
	$updated
}
