# Convert relative path to absolute path
# Usage: abspath=$(rel2abs ../../path)
# Arg 1 (destPath): The relative path to convert
# Arg 2 (sourcePath - optional): If supplied, destPath will be evaluated 
# relative to sourcePath
rel2abs() {
	local destPath="$1"
	local sourcePath="${2:-}"
	# Calculate absolute path in a subprocess to not mess with current working dir
	local absPath
	if absPath=$(_cdToPath "$sourcePath" 2>&1 && _cdToPath "$destPath" 2>&1 && { 
			# Move into destPath from sourcePath
			{ # If destination points to a file, append filename to path
				[ -f "$(basename "$destPath")" ] \
					&& echo "$(pwd)/$(basename "$destPath")"
			} || { # If destination is not a file, assume it points to a folder
				[ ! -f "$destPath" ] \
					&& pwd
			}
		}); then # If absolute path calculation succeeded
		echo "$absPath" # Return absolute path
	else # If an error occured while determining absolute path
		echo "Error: $absPath"
		exit 1 # Indicate failure
	fi
}

# This internal function moves into a supplied path which can be either a 
# directory or a file
# Arg 1 (toPath - optional): the path to move into. If ommitted, do nothing
_cdToPath() {
	local toPath="$1"
	[ -z "$toPath" ] || { # If path is omitted, do nothing
		[ -n "$toPath" ] && { # If path is supplied
			{ # If supplied path is a file, move into its directory
				[ -f "$toPath" ] && cd "$(dirname "$toPath")"
			} || { # If supplied path is not a file, assume it's a directory
				[ ! -f "$toPath" ] && cd "$toPath" || exit # Move into directory
			}
		}
	}
}
