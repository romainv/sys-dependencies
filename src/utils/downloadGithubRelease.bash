# Download a specific version of a Github repository
# Source: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
# Arg 1 (repo) The github repository (format: owner/name)
# Arg 2 (version) The version to install 
# Arg 3 (attr - optional) The attribute in the JSON returned by Github api that
# 	is used to identify the version
# Arg 4 (nameReg - optional) If specified, the regex pattern to match the name
# 	of the asset to download
# Returns: the path to the directory where the tarball was extracted
downloadGithubRelease() {
	local repo="$1"
	local version="$2" 
	local attr="${3:-tag_name}"
	local nameReg="$4"
	local tmpDir
	tmpDir=$(mktemp -d) # Create a temporary directory
	# Build the expression to filter the asset name
	local assetFilter=""
	[ -n "$nameReg" ] \
		&& assetFilter=" | map(select(.name | test(\"${nameReg}\"))) | ."
	# Retrieve download URL for supplied version
	local url
	url=$(curl -sS "https://api.github.com/repos/${repo}/releases" \
		| jq -r "map(select(.${attr} == \"${version}\")) \
			| .[0].assets${assetFilter}[0].browser_download_url")
	[[ ! "$url" == http* ]] \
		&& echo -e "Failed to retrieve download URL for $repo@$version: $url" \
		&& return 1 # Quit if error getting URL 
	local filename
	filename=$(basename "$url") # Extract filename from URL, including extension
	cd "$tmpDir" || return 1 # Move to temporary directory
	wget -q -nv -O "$filename" "$url" # Download asset
	[ ! -f "$filename" ] \
		&& echo "Failed to download $url: $filename missing" \
		&& return 1	# Quit if download failed
	if tar ztf "$filename" >/dev/null 2>&1; then
		# If file is a tar archive (tar can list its content)
		# Retrieve destination path 
		local dirname
		dirname=$(tar -tzf "$filename" | head -1 | cut -f1 -d"/") 
		tar zxf "$filename" # Extract downloaded file
		rm "$filename" # cleanup
		echo "$tmpDir/$dirname" # Return the extracted path
	else
		echo "$tmpDir" # Return the path containing the downloaded file
	fi
	cd ~- || return 1 # Go back to previous directory
}
