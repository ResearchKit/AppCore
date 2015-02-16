#!/bin/sh
rm -f "${SRCROOT}/ResearchKit/ResearchKit.framework"
if [ "$ARCHS" == "x86_64" ]
then
	echo "------Linking x86 Framework-------"
	ln -s "x86/ResearchKit.framework"  "ResearchKit/ResearchKit.framework"
else
	echo "------Linking ARM Framework-------"
	ln -s "arm/ResearchKit.framework"  "ResearchKit/ResearchKit.framework"
fi
