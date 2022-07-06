# Install a dependency
# Arg 1 (name) The name of the module 
# Arg 2 (version) The version of the module to install
installModule() {
	local name="$1"
	local version="$2"
	if $SPM_DRY_RUN; then # If missing modules should just be flagged
		echo "${YELLOW}missing${NORMAL}"
	else # If missing modules should be installed
		local result # Will contain output of install command
		if result=$(runInstall "$name" "$version"); then 
			# If install command ran successfully
			if checkInstall "$name" "$version" > /dev/null 2>&1; then 
				# Check again if installation worked
				local installedVersion
				installedVersion=$(getInstalledVersion "$name" "$version")
				[[ -n "$installedVersion" ]] \
					&& installedVersion=" (v${installedVersion})"
				echo "${GREEN}install complete${NORMAL}${installedVersion}" | nowrap
			else
				echo "${RED}install verification failed${NORMAL}" 
				# Display installation log
				[ -n "$result" ] && printf "Install log:\n%s\n" "$result" | indent 2 
				# Display check log
				local check
				check=$(checkInstall "$name" "$version" 2>&1)
				[ -n "$check" ] && printf "Check log:\n%s\n" "$check" | indent 2 
				return 1
			fi
		else # If install command failed
			echo "${RED}install failed${NORMAL}"
			[ -n "$result" ] && echo "$result" | indent 2 # Display error message 
			return 1 # Exit with error
		fi
	fi
	true # Indicate changes were made or are required
}
