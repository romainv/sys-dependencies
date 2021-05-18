# Clean a dependency import from the environment
unimportModule() {
	# Unset dependency attributes from the environment to avoid further conflicts
	local moduleExport
	for moduleExport in "${MODULE_EXPORTS[@]}"; do unset "$moduleExport"; done
	for moduleExport in "${MODULE_EXPORTS_OPT[@]}"; do unset "$moduleExport"; done
	# Reset working directory in case it was changed by dependency scripts
	cd "$PWD_BACKUP" || return 1
}
