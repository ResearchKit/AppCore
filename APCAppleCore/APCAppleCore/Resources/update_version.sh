#!/bin/sh

# In order to use a git-based versioning, do the following:
# 1) Copy this file to ${SRCROOT}
# 2) Ensure it has execute privileges. Execute `chmod a+x update_version.sh` from the command line to give the file execute privileges.
# 3) Add a `Run Script` build phase to the project and paste in the script `${SRCROOT}/update_version.sh`

set -o nounset	# Script exits if an undeclared variable is used
set -o errexit	# Script exits if a command fails

if git symbolic-ref HEAD 2>/dev/null	#	Are we in a git repository?
then
	VERSION=`git describe --tags --always --dirty`
	BUILD=`git rev-list HEAD | wc -l | tr -d ' '`
	
	echo "     Updating version to: ${VERSION}"
	echo "Updating build number to: ${BUILD}"
	
	defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleShortVersionString" "${VERSION}"
	defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "CFBundleVersion" "${BUILD}"
else
	echo "git repository was not detected"
	echo "Version and build numbers were not automatically set."
fi
