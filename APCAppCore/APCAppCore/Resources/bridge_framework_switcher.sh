#!/bin/sh
rm -f "${SRCROOT}/BridgeSDK/BridgeSDK.framework"
if [[ "$ARCHS" == "x86_64" ]];then
	echo "------Linking x86 Framework-------"
	ln -s "x86/BridgeSDK.framework"  "BridgeSDK/BridgeSDK.framework"
elif [[ "$ARCHS" == "i386" ]]; then
	echo "------Linking x86 Framework-------"
	ln -s "x86/BridgeSDK.framework"  "BridgeSDK/BridgeSDK.framework"
else
	echo "------Linking ARM Framework-------"
	ln -s "arm/BridgeSDK.framework"  "BridgeSDK/BridgeSDK.framework"
fi
