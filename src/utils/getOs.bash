# Detect which OS is running
getOs() {
	local os
	case "$OSTYPE" in
		solaris*) os="SOLARIS" ;; 
		darwin*)	os="MACOS" ;; 
		linux*)
			case "$(cat /etc/*release | grep ^NAME | tr -d 'NAME="')" in
				Ubuntu) os="UBUNTU" ;;
				"Amazon Linux"*) os="AMAZON_LINUX" ;;
				# TODO: detection of more versions of linux
				*) 			os="LINUX" ;; 
			esac ;;
		bsd*)     os="BSD" ;;
		msys*)    os="WINDOWS" ;;
		*)        os="UNKNOWN" ;;
	esac
	echo $os
}
