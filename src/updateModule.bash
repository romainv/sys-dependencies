# Update a module using its exported commands 
# Arg 1 (name) The name of the module 
# Arg 2 (version) The version of the module to update to
updateModule() {
	local name="$1"
	local version="$2"
	# Retrieve installed version
	local installedVersion
	installedVersion=$(getInstalledVersion "$name" "$version") 
	local result # Will contain command output
	if ! $SPM_FORCE && ! checkUpdates "$name" "$version" > /dev/null 2>&1; then 
		# checkUpdates shouldn't output anything. If it did, consider it an error
		# We run it again in a subshell to capture output. We don't run it in a
		# subshell the first time to allow setting env variables
		result=$(checkUpdates "$name" "$version" 2>&1)
		if [[ -n "$result" ]]; then
			printf "%b\n%s\n" "${RED}failed to check updates${NORMAL}" "${result}"
			exit 1
		else
			# If dependency is already up-to-date
			result="${GREY}up-to-date"
			[ -n "$installedVersion" ] && result+=" ($installedVersion)"
			result+="${NORMAL}"
			echo "$result" | nowrap
			false # Indicate no changes are required
		fi
	else
		if $SPM_DRY_RUN; then 
			# If updates should just be flagged
			# Retrieve latest version
			local latestVersion
			latestVersion=$(getLatestVersion "$name" "$version") 
			result="${YELLOW}"
			[ -n "$latestVersion" ] && result+="v${latestVersion} available" \
				|| result+="update available"
			[ -n "$installedVersion" ] \
				&& result+="${GREY} (v${installedVersion} installed)"
			echo "$result${NORMAL}" | nowrap
		else
			if result=$(runUpdates "$name" "$version"); then # Update module
				if ! checkUpdates "$name" "$version" > /dev/null 2>&1; then 
					# Run update check again
					local newInstalledVersion
					newInstalledVersion=$(getInstalledVersion "$name" "$version")
					result="${GREEN}update complete${NORMAL}"
					[ -n "$newInstalledVersion" ] \
						&& result+=" (${installedVersion} > ${newInstalledVersion})"
					echo "$result" | nowrap
				else
					echo "${RED}post-update check failed${NORMAL}"
					# Display error message if any
					[ -n "$result" ] && echo "$result" | indent 2 
					exit 1 # Exit with error
				fi
			else
				echo "${RED}update failed${NORMAL}" 
				# Display error message if any
				[ -n "$result" ] && echo "$result" | indent 2 
				exit 1 # Exit with error
			fi
		fi
		true # Indicate changes were made or are required
	fi
}
