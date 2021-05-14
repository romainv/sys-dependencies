# Contains functions to read and write in INI config files, with support for 
# sections
# Inspired from https://gist.github.com/thomedes/6201620

# Read an entire section
# Arg 1: The section
# Arg 2: The config file
readConfSection() {
	local section="$1"
	local confFile="$2"
	# Fail if file is empty (sed commands behave differently in this case)
	[ -s "$confFile" ] && \
		sed -n -E -e '
			'"$(_sectionRange "$section")"' { # Within the supplied section
				/^[ \t]*([^#; \t][^ \t=]*).*=[ \t]*(.*)/ {
					# For each key definition (ignore comments lines, section headers...) 
					s//\1=\2/ # Remove whitespaces around key and =  
					p # Print the line
					h # Add the line to the buffer space to indicate we found matches
				}
			}
			'"$(_exitWithCode 100)"' # Exit with code 100 if no matches were found
		' "$confFile"
}

# Read KEY from [SECTION]
# Arg 1: The key
# Arg 2: The section
# Arg 3: The config file
readConfKey() {
	local key="$1"
	local section="$2"
	local confFile="$3"
	# Fail if file is empty (sed commands behave differently in this case)
	[ -s "$confFile" ] && \
		sed -n -E -e '
			'"$(_sectionRange "$section")"' { # Within the supplied section
				/'"$(_matchKeyValue "$key")"'/ { 
					# If we found a match for the request key
					s//\2/ # Keep only the value
					p # Print the value
					# Exit with success so that no more matches are processed if there 
					# are duplicates
					q0 
				}
			}
			'"$(_exitWithCode 100)"' # Exit with code 100 if no matches were found
		' "$confFile"
}

# Set KEY in [SECTION]
# Arg 1: The key
# Arg 2: The value
# Arg 3: The section
# Arg 4: The config file
writeConfKey() {
	local key="$1"
	# Escape backskashes so special characters are not interpreted
	local value="${2//\\/\\\\}" 
	local section="$3"
	local confFile="$4"
	local status= # Will contain exit codes
	if [ ! -s "$confFile" ]; then # If the file is empty
		# Append to file (sed scripts don't work on empty files)
		echo -e "[${section}]\n${key}=${value}" >> "$confFile" 
	else
		# Attempt to replace an existing key definition in the section - if both 
		# key and section exist
		sed -i -E -e '
			'"$(_sectionRange "$section")"' { # In the section range
				/'"$(_matchKeyValue "$key")"'/ { # On the key definition line
					# Note: leaving the left-hand part of s empty uses the last match, 
					# i.e. key definition here
					s//\1'"${value//\//\\\/}"'/ # Replace value (escape slashes)
					# Puts the line in the hold space as a marker that a substitution was 
					# made
					h 
				}
			}
			# Exit with code 100 if no substitutions were made
			'"$(_exitWithCode 100)"' 
		' "$confFile" >/dev/null 2>&1
		status=$?
		# Exit with sed's exit code if success or unexpected error
		[[ $status -eq 0 || ! $status -eq 100 ]] && exit $status 
		# If prior attempt failed, try to append a new key definition in the 
		# section - if the section exists
		sed -i -E -e '
		/'"$(_sectionHeader "$section")"'/ { # On the section header line
				# Append the key definition below the section header
				a '"$key"'='"$value"'
				# Put the section header in the hold space as a marker that the key was 
				# defined
				h 
 			}
			# Exit with code 100 if no substitutions were made
			'"$(_exitWithCode 100)"' 
			' "$confFile" >/dev/null 2>&1
		status=$?
		# Exit with sed's exit code if success or unexpected error
		[[ $status -eq 0 || ! $status -eq 100 ]] && exit $status 
		# If both section and key definition don't exist, add them to the file
		echo -e "[${section}]\n${key}=${value}" >> "$confFile" 
	fi
}

# Generate the regex pattern to match a section's range
# Arg 1 (section) The section to select
_sectionRange() {
	local section="$1"
	# From section header to next section, or end of file 
	echo '/^[ \t]*\['$section'\]/,/\[/' 
}

# Generate the regex pattern to match a section's header
# This will capture the section's name
# Arg 1 (section) The section to select
_sectionHeader() {
	local section="$1"
	# Matches '[section]' with optional whitespaces before
	echo '^[ \t]*\[('$section')\]' 
}

# Generate the regex pattern to match a 'key=value' line
# It captures the left side of the assignment in group \\1 and the value in \\2
# Arg 1 (key) The key to match
_matchKeyValue() {
	local key="$1"
	# Matches 'key=value' with optional white-spaces around 'key' and '='
	echo '(^[ \t]*'$key'[ \t]*=[ \t]*)(.*)' 
}

# Helper function to exit with error if sed's buffer space is empty, and exit 
# successfully otherwise
# Arg 1 (code) The exit code to return if buffer space is empty
_exitWithCode() {
	local code="$1"
	echo '$ { # Once we reach the last line of the file
		x # Swap the pattern space and buffer space
		/./ {
			# If there was anything in the buffer space (now the pattern space), i.e.
			# a substitution was made
			x # Swaps buffer and pattern spaces again
			q0 # Quit successfully
		}
		# If we reach here, it means there was no substitution made
		x # Swap buffer and patter spaces again
		q'"$code"' # Quit with error
	}'
}
