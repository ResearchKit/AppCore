#!/bin/sh
#
#  get_debug_ip_address.sh
#  AppCore
#
# Copyright (c) 2015, Apple Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1.  Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2.  Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# 3.  Neither the name of the copyright holder(s) nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission. No license is granted to the trademarks of
# the copyright holders even if such marks are included in this software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


#
# Extracts the IP address of the build machine and saves
# it to a pseudo-environment variable which is loaded at
# run time.  Used during debugging, when logging unencrypted
# Sage data to a local server to make sure the upload is
# working correctly.
#
# This file is used by the main apps, but is stored in AppCore.
# Each main app has a build script which runs this file.
#


#
# Notes on this "if" statement syntax:
#
# -	The CONFIGURATION variable is provided by Xcode:  https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
#
# -	The "[" is a COMMAND.  Leave spaces before and after it.  http://stackoverflow.com/questions/4277665/how-do-i-compare-two-string-variables-in-an-if-statement-in-bash
#
# - The "then" goes on the next line:  it's a separate
#	command from the "if" line.  (Help link:  same as
#	for the "[", above.)
#

if [ "$CONFIGURATION" == "Debug" ]
then

	#
	# A little shell script to extract the build machine's IP address.
	#
	# Here's what each component of the line below does.  Mentally split
	# it into pieces at each "|" ("pipe") character:
	#
	#	ifconfig:
	#		run "ifconfig".  This generates a page of IP address data:
	#		wireless, wired, IPv6, everything.  We need to filter it.
	#
	#	egrep ...
	#		shove the results of "ifconfig" through  "egrep," looking
	#		for patterns like: "inet xxx.xxx.xxx.xxx".
	#
	#	cut ...
	#		shove the results of egrep through "cut," which extracts
	#		the 2nd space-delimited column of data:  the IP address.
	#
	#	grep -v ...
	#		the "cut" operation gave us 2 IP addresses.  Remove the one
	#		with a "127" in it.  The result should be our machine's real
	#		IP address.
	#
	#	`...`
	#		By wrapping the whole thing in a pair of "backtick"
	#		marks (reverse single-quotation marks), we tell
	#		Unix:  please run this line of code, put the results
	#		into a string, and feed me the string.
	#
	ipAddress=`ifconfig | egrep -o "inet (\\d+\\.\\d+\\.\\d+\\.\\d+)\\D" | cut -d ' ' -f 2 | grep -v "127"`


	# Store it as a key/value pair in a file in the build's
	# temp directory (which happens to be inside the compiled
	# executable package, as a .plist file).  Search the code
	# for the string "BUILD_MACHINE_IP_ADDRESS" to see how
	# we're using this.
	defaults write "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH%.*}" "BUILD_MACHINE_IP_ADDRESS" "${ipAddress}"

	echo "We're in 'DataVerificationServer' mode.  Saving build machine's IP address, [${ipAddress}], into a .plist file, in variable BUILD_MACHINE_IP_ADDRESS, for use in the app."

fi

