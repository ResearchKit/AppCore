#!/bin/sh
rm -f "${SRCROOT}/ResearchKit/ResearchKit.framework"
if [ "$ARCHS" == "x86_64" ]
then
	echo "------Linked x86 Framework-------"
	ln -s "${SRCROOT}/ResearchKit/x86/ResearchKit.framework"  "${SRCROOT}/ResearchKit/ResearchKit.framework"
else
	echo "------Linked arm Framework-------"
	ln -s "${SRCROOT}/ResearchKit/arm/ResearchKit.framework"  "${SRCROOT}/ResearchKit/ResearchKit.framework"
fi
