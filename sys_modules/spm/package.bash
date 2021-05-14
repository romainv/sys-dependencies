#!/bin/bash
# Manage spm's installation on the host system, which is essentially clones the
# repository and hooks into .bashrc

checkInstall() {
	[ -d "$SPM_DIR/.git" ]
}

runInstall() {
	local remote="https://github.com/romainv/sys-dependencies.git"
	git clone "$remote" "$SPM_DIR" 2>&1
}

getInstalledVersion() {
	"$SPM_DIR"/spm --version | sed -E "s/spm ([0-9.]+)$/\1/g"
}

getLatestVersion() { 
	curl -sS https://api.github.com/repos/romainv/sys-dependencies/releases \
		| jq -r ".[0].name"
}

checkUpdates() { 
	local check
	if ! check=$(cd "$SPM_DIR" && git remote update 2>&1 && git status 2>&1); then
		# If update check failed
		echo "$check" && return 1
	fi
	# If update check succeeded
	[[ ! "$check" =~ "Your branch is up to date" ]]
}

runUpdates() { 
	git -C "$SPM_DIR" pull 2>&1
}
