#!/bin/bash
# Manage a git repository: clone it if missing, or keep it updated

checkInstall() {
	local dir="${1/#\~/$HOME}" # Expand ~ to home directory 
	[ -d "${dir}" ]
}

runInstall() {
	local dir="${1/#\~/$HOME}" # Expand ~ to home directory 
	local remote="$2"
	git clone "$remote" "$dir" 2>&1
}

# We don't use versioning
getInstalledVersion() { true; }
getLatestVersion() { true; }

checkUpdates() {
	local dir="${1/#\~/$HOME}" # Expand ~ to home directory 
	local check
	if ! check=$(cd "$dir" \
			&& git remote update 2>&1 \
			&& git status 2>&1); then
		# If update check failed
		echo "$check" && return 1
	fi
	# If update check succeeded
	[[ ! "$check" =~ "Your branch is up to date" ]]
}

runUpdates() {
	local dir="${1/#\~/$HOME}" # Expand ~ to home directory 
	git -C "$dir" pull 2>&1
}
