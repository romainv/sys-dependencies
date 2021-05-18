# Import dependencies

# Update a configuration file in ini format
# Arg 1 (targetFile): The file to update
# Arg 2 (params): Description of the key-values in JSON format, where
# key-values are nested in section headers
# Arg 3 (checkOnly - optional) "true" to perform a check and no changes
iniConfigFile() {
	local targetFile="$1"
	local params="$2"
	local checkOnly="$3"
	local updated=false # Indicate whether updates were made / are required
	#	Parse values from JSON
	local section
	for section in $(jq -r "to_entries | .[] | @base64" <<< "${params}"); do 
		# Parse each section
		section=$(echo "${section}" | base64 --decode) # Decode base64
		local header keyValues
		header=$(jq -j ".key" <<< "${section}") # Name of section header
		keyValues=$(jq -j ".value" <<< "${section}") # Key-value pairs for section
		local keyValue
		for keyValue in $(jq -r "to_entries | .[] | @base64" \
			<<< "${keyValues}"); do 
			keyValue=$(echo "${keyValue}" | base64 --decode) # Decode base64
			# Parse each key/value pair
			local key value
			key=$(jq -j ".key" <<< "${keyValue}")
			value=$(jq -j ".value" <<< "${keyValue}" \
				| replaceParameters) # Replace params with their values
			# Retrieve any existing value
			local previousValue status
			previousValue=$(readConfKey "$key" "$header" "$targetFile")
			status=$?
			if [[ ! $status -eq 0 && ! $status -eq 100 ]]; then
				echo "Error retrieving value for ${key} in ${targetFile}"
				return $status # Exit if an error occurred
			fi
			if [[ "$previousValue" != "$value" ]]; then
				# If an update is required
				local result
				if [[ "$checkOnly" == "true" ]] \
					|| result=$(writeConfKey "$key" "$value" "$header" "$targetFile" \
						2>&1); then
					updated=true # Indicate update was successful
				else # If an error occured
					[ -n "$result" ] && echo "$result"
					return 1
				fi
			fi
		done
	done
	# Indicate if file was updated or not
	$updated && return 0 || return 2
}
