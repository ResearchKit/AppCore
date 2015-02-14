#!/bin/sh
rm -f "${SRCROOT}/AppCore/APCAppCore/ResearchKit/ResearchKit.framework"
if [ "$ARCHS" == "x86_64" ]
then
	echo "------Linked x86 Framework-------"
	ln -s "${SRCROOT}/AppCore/APCAppCore/ResearchKit/x86/ResearchKit.framework"  "${SRCROOT}/AppCore/APCAppCore/ResearchKit/ResearchKit.framework"
else
	echo "------Linked arm Framework-------"
	ln -s "${SRCROOT}/AppCore/APCAppCore/ResearchKit/arm/ResearchKit.framework"  "${SRCROOT}/AppCore/APCAppCore/ResearchKit/ResearchKit.framework"
fi
