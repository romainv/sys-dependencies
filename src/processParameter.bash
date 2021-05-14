# Process a module parameter
# Arg 1 (paramName) The parameter name
# Arg 2 (defaultValue) The parameter's default value
processParameter() {
	local paramName="$1"
	local defaultValue="$2"
	local changes=0 # Will contain number of changes
	local isSecret="false" # Whether current parameter is a secret
	if [[ "$paramName" =~ .*\*$ ]]; then
		# If param ends with *
		isSecret="true" 
		paramName="${paramName::-1}" # Remove trailing * from parameter name
	fi
	local prefix # We'll reuse it
	prefix="$(displayIcon "parameter") ${paramName}" 
	# shellcheck disable=SC2086
	defaultValue="$(eval echo -e $defaultValue)" # Expand any variables
	# Retrieve default parameter value
	local paramValue="$defaultValue"
	if [ -z "$paramValue" ]; then
		# If no previous value nor default were found:
		if $SPM_DRY_RUN; then 
			# If we're in dry-run mode
			paramValue="missing" # Mark param as missing
		else
			paramValue="?" # Will request user input 
		fi
	fi
	# Display value
	local displayValue 
	if [[ "$isSecret" == "true" ]]; then # Secret value
		displayValue="***"
	else # Normal value
		displayValue="${paramValue//\\/\\\\}" # Escape backslashes in value
	fi
	# Ask for user input if needed 
	if [[ "$paramValue" == "?" ]]; then
		echo -e "${prefix}?"
		if [[ "$isSecret" == "true" ]]; then # If parameter is secret
			read -e -r -s -p "> " paramValue # Don't display input value
		else # If parameter is not secret
			read -e -r -p "> " paramValue # Display input value
			displayValue="${paramValue//\\/\\\\}" # Update displayed value 
		fi
		# Erase prompt
		echo -e "${CLEAR_PREVIOUS_LINE}${CLEAR_PREVIOUS_LINE}${PREVIOUS_LINE}" 
	fi
	# shellcheck disable=SC2034
	SPM_PARAMS[$paramName]=$paramValue # Update parameter value
	# Save and display final value
	if [[ "$paramValue" != "$defaultValue" ]]; then # If the value changed
		echo -e "${prefix}=${YELLOW}${displayValue}${NORMAL}" | nowrap
		changes=$((changes+1)) # Increment number of changes
	elif ! $SPM_HIDE_UNCHANGED; then 
		# If parameter is unchanged and should be displayed
		echo -e "${prefix}=${GREY}${displayValue}${NORMAL}" | nowrap
	fi
	# Indicate whether there have been changes
	[ "$changes" -gt 0 ]
}
