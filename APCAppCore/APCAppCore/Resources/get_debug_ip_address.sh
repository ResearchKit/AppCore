#!/bin/sh

#  get_debug_ip_address.sh
#  AppCore
#
#  Copyright (c) 2015 Apple, Inc. All rights reserved.


# Extract the IP address of the build machine.
# Used during debugging.
#
# Here's how to read the line of code below.  Mentally split
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
