# Install and configure system dependencies on the local machine
# Usage instructions
SPM_USAGE=$(cat <<-END
Commands:
  spm install           install all system dependencies defined in package.json
  spm install <module>  install a specific system dependency
  spm install spm       install spm itself on your system
  spm update            update all system dependencies defined in package.json
  spm update <module>   update a specific system dependency
  spm update spm        update spm itself
  spm help              show this help message and exit
  spm version           display the current version of spm

Optional arguments:
  -h, --help            show this help message and exit
  -d, --dry-run         only check for changes but don't execute them
  -s, --skip-core       don't install spm's self dependencies
  -q, --hide-unchanged  don't display modules which didn't change
	-f, --force           (re)install the dependencies even if not needed
  -v, --version         display the current version of spm

Optional env variables:
  SPM_SKIP_CORE         set to 'true' to not install spm's self dependencies
  SPM_DRY_RUN           set to 'true' to only check for changes
  SPM_UPDATE            set to 'true' to update dependencies
	SPM_FORCE             set to 'true' to force (re)installing dependencies
  SPM_HIDE_UNCHANGED    set to 'true' to hide unchanged modules
END
)
export SPM_USAGE
spm() {
	# Check and retrieve CLI arguments
	local args # Will contain the command arguments
	local commandArg="" # Will contain the command to execute
	local skipCore=${SPM_SKIP_CORE:-false} # Whether to install core dependencies
	SPM_DRY_RUN=${SPM_DRY_RUN:-false} # Whether to make any changes 
	SPM_UPDATE=${SPM_UPDATE:-false} # Whether to update installed dependencies
	SPM_FORCE=${SPM_FORCE:-false} # Whether to force the installation or update
	# Whether unchanged dependencies should be hidden
	SPM_HIDE_UNCHANGED=${SPM_HIDE_UNCHANGED:-false} 
	MODULES=() # Will contain the modules to process 
	while [ "$1" != "" ]; do
		case $1 in
			# Named arguments
			-d|--dry-run) SPM_DRY_RUN=true ;;
			-q|--hide-unchanged) SPM_HIDE_UNCHANGED=true ;;
			-s|--skip-core) skipCore=true ;;
			-f|--force) SPM_FORCE=true ;;
			-h|--help) commandArg="help" ;;
			-v|--version) commandArg="version" ;;
			# First positional argument: the command to execute
			install|update|help|version) commandArg="$1" ;;
			-*) echo "Warning: parameter '$1' not recognized" && exit 1 ;;
			# Further positional arguments: specific modules
			*) MODULES+=("$1") ;; 
		esac
		shift
	done
	export SPM_DRY_RUN SPM_FORCE SPM_UPDATE SPM_HIDE_UNCHANGED MODULES

	# Display help if needed
	if [ "$commandArg" != "install" ] \
		&& [ "$commandArg" != "update" ] \
		&& [ "$commandArg" != "version" ] \
		|| [ "$commandArg" = "help" ]; then
		# If command is not recognized, or if help was requested
		printf "%b\n" "$SPM_USAGE"
		return
	fi

	# Setup dependencies and env variables
	if [ -z "${SPM_DIR+x}" ]; then
		# If SPM_DIR was not set
		# Retrieve the current file's parent directory, including when symlinked
		SPM_DIR=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" \
			&& cd .. && pwd)
		export SPM_DIR
	fi
	
	# Display version if requested
	if [ "$commandArg" = "version" ]; then
		sed -r -n -e '
			/"version"/ { # On the line containing the version
				# Extract the version number and prefix it
				s/.*"version": "([0-9.]+).*/spm \1/
				p # Print the transformed line
			}
		' "$SPM_DIR/package.json"
		return 
	fi

	# Prepare install/update commands dependencies
	# shellcheck source=./utils/index.bash
	source "${SPM_DIR}/src/utils/index.bash" 
	# shellcheck source=./index.bash
	source "${SPM_DIR}/src/processModule.bash" 
	# Backup current working path in case it is modified by dependencies
	export PWD_BACKUP="$PWD" 
	# Current operating system
	CURRENT_OS=$(getOs)
	export CURRENT_OS
	# Initialize parameters
	declare -A SPM_PARAMS # Create an associative array
	export SPM_PARAMS

	# Define which modules should be processed
	# Set the default module that should be processed if none were specified
	[[ "${#MODULES[@]}" -eq 0 ]] && MODULES+=("$(upsearch "package.json")")
	# Add core dependencies if required
	! $skipCore && MODULES=("core" "${MODULES[@]}")

	# Run the install/update commands
	[ "$commandArg" = "update" ] && export SPM_UPDATE=true	
	# Prompt for sudo password if necessary, so the prompt doesn't come up 
	# randomly later on
	promptSudo \
		|| echo -e "${YELLOW}Warning: failed to get root permissions${NORMAL}"
	# Process dependencies recursively
	local totalChanges=0
	for module in "${MODULES[@]}"; do
		if processModule "$module"; then
			# If module had changes
			totalChanges=$((totalChanges+1)) # Increment changes 
		elif $SPM_HIDE_UNCHANGED; then 
			# If module had no changes and we should hide it
			echo -e "${LINE_START}${CLEAR_LINE}${PREVIOUS_LINE}" # Hide module
		fi
	done
	# Display at least something if we hide everything so far
	[ $totalChanges -eq 0 ] \
		&& $SPM_HIDE_UNCHANGED \
		&& echo "${GREY}All modules are up-to-date${NORMAL}"
	# Make sure we return a positive value so we can trigger further commands
	true 
}
