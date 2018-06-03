#!/bin/bash
#
# Master build script
#
# This will:
#   1. Build OpenSSL libraries for macOS and iOS using the `build.sh`
#   2. Generate the `openssl.h` umbrella header for macOS and iOS based on the contents of
#      the `include-macos` and `include-ios` directories.
#
# Wyllys Ingersoll
# mailto:wyllys@gmail.com
# May 22, 2018
##

### Configuration
OPENSSL_VERSION="1_1_1-pre7"
#OPENSSL_VERSION="1.1.0-stable"

FRAMEWORK="openssl.framework"
FRAMEWORK_BIN="${FRAMEWORK}/openssl"

# macOS configuration
MAC_HEADER_DEST="OpenSSL-macOS/OpenSSL-macOS/openssl.h"
MAC_HEADER_TEMPLATE="OpenSSL-macOS/OpenSSL-macOS/openssl_umbrella_template.h"
MAC_INCLUDES_DIR="include-macos"
MAC_LIB_DIR="lib-macos"
MAC_BUILD_DIR="OpenSSL-macOS/bin"

# iOS configuration
IOS_HEADER_DEST="OpenSSL-iOS/OpenSSL-iOS/openssl.h"
IOS_HEADER_TEMPLATE="OpenSSL-iOS/OpenSSL-iOS/openssl_umbrella_template.h"
IOS_INCLUDES_DIR="include-ios"
IOS_LIB_DIR="lib-ios"
IOS_BUILD_DIR="OpenSSL-iOS/bin"

UMBRELLA_HEADER_SCRIPT="framework_scripts/create_umbrella_header.sh"
UMBRELLA_STATIC_INCLUDES="framework_scripts/static_includes.txt"

###
function fail()
{
    echo "Failed: $@" >&2
    exit 1
}

function usage()
{
	[[ "$@" = "" ]] || echo "$@" >&2
	echo "Usage:" >&2
	echo "$0 clone [branch]|build|valid [ios|macos]|clean" >&2
	echo "    clone   Clone OpenSSL source repo and checkout a branch to build (set OPENSSL_BRANCH_NAME in this script)." >&2
	echo "    build   Builds OpenSSL libraries from source." >&2
	echo "    header  Generates macOS and iOS umbrella headers." >&2
	echo "    valid   Validates the frameworks." >&2
	echo "    clean   Removes all build artifacts." >&2
	echo "" >&2
	echo "    ex.: $0 build" >&2
	echo "    ex.: $0 clean" >&2
	echo "" >&2
    exit 1
}

function clone()
{
	#
	# Clone the tree and then make a tgz file because we re-use the source
	# tree to building each different architecture.
	#
	branch=${1:-"master"}
	echo "BRANCH: $branch"
	here=$(pwd)
        pushd . > /dev/null
	cd /tmp
	mkdir openssl-$OPENSSL_VERSION
	git clone https://github.com/openssl/openssl.git openssl-$OPENSSL_VERSION
	cd openssl-$OPENSSL_VERSION
	if [ ! -z "$branch" ]; then
		git checkout $branch
		pwd
	fi
	cd ..
	tar cf $here/openssl-$OPENSSL_VERSION.tgz openssl-$OPENSSL_VERSION
	# rm -rf openssl-$OPENSSL_VERSION
	popd . > /dev/null
}

function build()
{
	# Build OpenSSL
	echo "Building OpenSSL ${OPENSSL_VERSION}..."
	source ./build.sh
	echo "Finished building OpenSSL ${OPENSSL_VERSION}"

	header
	
	echo "Build complete. Please follow the steps under \"Building\" in the README.md file to create the macOS and iOS frameworks."
}

function header()
{
	# export CONTENT=$(<"${UMBRELLA_STATIC_INCLUDES}")

	# Create the macOS umbrella header
	HEADER_DEST="${MAC_HEADER_DEST}"
	HEADER_TEMPLATE="${MAC_HEADER_TEMPLATE}"
	INCLUDES_DIR="${MAC_INCLUDES_DIR}"
	source "${UMBRELLA_HEADER_SCRIPT}"
	echo "Created $HEADER_DEST"

	# Create the iOS umbrella header
	HEADER_DEST="${IOS_HEADER_DEST}"
	HEADER_TEMPLATE="${IOS_HEADER_TEMPLATE}"
	INCLUDES_DIR="${IOS_INCLUDES_DIR}"
	source "${UMBRELLA_HEADER_SCRIPT}"
	echo "Created $HEADER_DEST"
}

function valid()
{
	local args=${@:-"ios" "macos"}
	for OS in ${args[@]}
	do
		case $OS in
			ios)
				valid_ios
			;;
			macos)
				valid_macos
			;;
			*)
				# Unknown option
				usage
			;;
		esac
	done
}

function valid_ios()
{
	echo "Validating ios framework..."

	local VALID=1
	local BUILD_DIR="${IOS_BUILD_DIR}"
	local LIB_BIN="${BUILD_DIR}/${FRAMEWORK_BIN}"
	
	if [ -r "${LIB_BIN}" ]; then
		# Check expected architectures
		local REZ=$($LIPO_B -info "${LIB_BIN}")
		if [ "$REZ" != "Architectures in the fat file: OpenSSL-iOS/bin/openssl.framework/openssl are: i386 x86_64 armv7 armv7s arm64 " ]; then
			echo "ERROR: Unexpected result from $LIPO_B: \"${REZ}\""
			VALID=0
		else
			echo " GOOD: ${REZ}"
		fi

		# Check for bitcode where expected
		local ARCHS=("arm64" "armv7" "armv7s")
		for ARCH in ${ARCHS[*]}
		do
			local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B LLVM)
			if [ "$REZ" == "" ]; then
				echo "ERROR: Did not find bitcode slice for ${ARCH}"
				VALID=0
			else
				echo " GOOD: Found bitcode slice for ${ARCH}"
			fi
		done
	
		# Check for bitcode where not expected
		local ARCHS=("i386")
		for ARCH in ${ARCHS[*]}
		do
			local REZ=$($OTOOL_B -arch ${ARCH} -l "${LIB_BIN}" | $GREP_B LLVM)
			if [ "$REZ" != "" ]; then
				echo "ERROR: Found bitcode slice for ${ARCH}"
				VALID=0
			else
				echo " GOOD: Did not find bitcode slice for ${ARCH}"
			fi
		done
		
		local EXPECTING=("${BUILD_DIR}/${FRAMEWORK}/Modules/module.modulemap")
		for EXPECT in ${EXPECTING[*]}
		do
			if [ -f "${EXPECT}" ]; then
				echo " GOOD: Found expected file: \"${EXPECT}\""
			else
				echo "ERROR: Did not file expected file: \"${EXPECT}\""
				VALID=0
			fi
		done

	else
		echo "ERROR: \"${LIB_BIN}\" not found. Please be sure it has been built (see README.md)"
		VALID=0
	fi
	
	if [ $VALID -ne 1 ]; then
		fail "Invalid framework"
	fi
}

function valid_macos()
{
	echo "Validating macos framework..."
	
	local VALID=1
	local BUILD_DIR="${MAC_BUILD_DIR}"
	local LIB_BIN="${BUILD_DIR}/${FRAMEWORK_BIN}"
	
	if [ -r "${LIB_BIN}" ]; then
		# Check expected architectures
		local REZ=$($LIPO_B -info "${LIB_BIN}")
		if [ "$REZ" != "Non-fat file: OpenSSL-macOS/bin/openssl.framework/openssl is architecture: x86_64" ]; then
			echo "ERROR: Unexpected result from $LIPO_B: \"${REZ}\""
			VALID=0
		else
			echo " GOOD: ${REZ}"
		fi
		
		local EXPECTING=("${BUILD_DIR}/${FRAMEWORK}/Modules/module.modulemap")
		for EXPECT in ${EXPECTING[*]}
		do
			if [ -f "${EXPECT}" ]; then
				echo " GOOD: Found expected file: \"${EXPECT}\""
			else
				echo "ERROR: Did not file expected file: \"${EXPECT}\""
				VALID=0
			fi
		done

	else
		echo "ERROR: \"${LIB_BIN}\" not found. Please be sure it has been built (see README.md)"
		VALID=0
	fi
	
	if [ $VALID -ne 1 ]; then
		fail "Invalid framework"
	fi
}

function clean()
{
	echo "Cleaning iOS..."
	set -x
	$RM_B "${IOS_HEADER_DEST}"
	$RM_B -rf "${IOS_INCLUDES_DIR}"
	$RM_B -rf "${IOS_LIB_DIR}"
	$RM_B -rf "${IOS_BUILD_DIR}"
	[ $DEBUG -ne 1 ] && set +x

	echo "Cleaning macOS..."
	set -x
	$RM_B "${MAC_HEADER_DEST}"
	$RM_B -rf "${MAC_INCLUDES_DIR}"
	$RM_B -rf "${MAC_LIB_DIR}"
	$RM_B -rf "${MAC_BUILD_DIR}"
	[ $DEBUG -ne 1 ] && set +x

	echo "Clean complete"
}


DEBUG=${DEBUG:-0}
export DEBUG

set -eu
[ $DEBUG -ne 0 ] && set -x

# Fully qualified binaries (_B suffix to prevent collisions)
RM_B="/bin/rm"
GREP_B="/usr/bin/grep"
LIPO_B="/usr/bin/lipo"
OTOOL_B="/usr/bin/otool"

if [[ $# -eq 0 ]]; then
	usage
fi

command="$1"
shift
case $command in
    clone)
		clone $1
    ;;
    build)
		if [[ $# -le 0 ]]; then
			build
		else
			usage
		fi
    ;;
    header)
		if [[ $# -le 0 ]]; then
			header
		else
			usage
		fi
    ;;
    valid)
		valid $@
    ;;
    clean)
		if [[ $# -le 0 ]]; then
			clean
		else
			usage
		fi
    ;;
    *)
		# Unknown option
		usage
    ;;
esac

