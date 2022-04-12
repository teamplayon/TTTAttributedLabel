#!/bin/bash
set -eE
trap 'printf "\e[31m%s: %s\e[m\n" "ERROR($?): $BASH_SOURCE:$LINENO $BASH_COMMAND"' ERR

PROJECT="Carthage/TTTAttributedLabel.xcodeproj"
TARGET="TTTAttributedLabel"
SCHEME="TTTAttributedLabel"
SCHEMETV="TTTAttributedLabel tvOS"

BUILD="build"
ARCHIVES="$BUILD/archives"
XCF="$BUILD/xcf"
BINDINGS="$BUILD/bindings"

rm -rf "$XCF"

#----- Make macCatalyst archive
xcodebuild archive \
 -project "$PROJECT" \
 -scheme "$SCHEME" \
 -archivePath "$ARCHIVES/macCatalyst.xcarchive" \
 -sdk iphoneos \
 -destination 'platform=macOS,variant=Mac Catalyst' \
 SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES SUPPORTS_MACCATALYST=YES

#----- Make iOS Simulator archive
xcodebuild archive \
 -project "$PROJECT" \
 -scheme "$SCHEME" \
 -archivePath "$ARCHIVES/iOS-simulator.xcarchive" \
 -sdk iphonesimulator \
 -destination 'generic/platform=iOS Simulator' \
 SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#----- Make iOS device archive
xcodebuild archive \
 -project "$PROJECT" \
 -scheme "$SCHEME" \
 -archivePath "$ARCHIVES/iOS.xcarchive" \
 -sdk iphoneos \
 -destination 'generic/platform=iOS' \
 SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#----- Make tvOS Simulator archive
xcodebuild archive \
 -project "$PROJECT" \
 -scheme "$SCHEMETV" \
 -archivePath "$ARCHIVES/tvOS-simulator.xcarchive" \
 -sdk appletvsimulator \
 -destination 'generic/platform=tvOS Simulator' \
 SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#----- Make tvOS device archive
xcodebuild archive \
 -project "$PROJECT" \
 -scheme "$SCHEMETV" \
 -archivePath "$ARCHIVES/tvOS.xcarchive" \
 -sdk appletvos \
 -destination 'generic/platform=tvOS' \
 SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

#----- Make XCFramework
xcodebuild -create-xcframework \
 -framework "$ARCHIVES/tvOS-simulator.xcarchive/Products/Library/Frameworks/$TARGET.framework" \
 -framework "$ARCHIVES/tvOS.xcarchive/Products/Library/Frameworks/$TARGET.framework" \
 -framework "$ARCHIVES/iOS-simulator.xcarchive/Products/Library/Frameworks/$TARGET.framework" \
 -framework "$ARCHIVES/iOS.xcarchive/Products/Library/Frameworks/$TARGET.framework" \
 -framework "$ARCHIVES/macCatalyst.xcarchive/Products/Library/Frameworks/$TARGET.framework" \
 -output "$XCF/$TARGET.xcframework"

sharpie bind -sdk iphoneos -o "$BINDINGS" -n Xamarin.TTTAttributedLabel -scope TTTAttributedLabel TTTAttributedLabel/TTTAttributedLabel.h
