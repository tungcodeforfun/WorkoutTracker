#!/bin/bash

# Script to configure WorkoutTracker as iOS-only app
echo "Configuring WorkoutTracker for iOS only..."

# Backup the original project file
cp WorkoutTracker.xcodeproj/project.pbxproj WorkoutTracker.xcodeproj/project.pbxproj.backup

# Update supported platforms to iOS only
sed -i '' 's/SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";/SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";/g' WorkoutTracker.xcodeproj/project.pbxproj

# Update targeted device family to iPhone and iPad only (remove Vision Pro)
sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2,7";/TARGETED_DEVICE_FAMILY = "1,2";/g' WorkoutTracker.xcodeproj/project.pbxproj

# Remove macOS deployment target
sed -i '' '/MACOSX_DEPLOYMENT_TARGET = 15.4;/d' WorkoutTracker.xcodeproj/project.pbxproj

# Remove Vision OS deployment target
sed -i '' '/XROS_DEPLOYMENT_TARGET = 2.4;/d' WorkoutTracker.xcodeproj/project.pbxproj

# Update SDK root to iOS
sed -i '' 's/SDKROOT = auto;/SDKROOT = iphoneos;/g' WorkoutTracker.xcodeproj/project.pbxproj

echo "✅ Project configured for iOS only!"
echo "✅ Supported platforms: iPhone and iPad"
echo "✅ Removed macOS and visionOS support"
echo ""
echo "🔄 Please clean and rebuild your project in Xcode:"
echo "   1. Product → Clean Build Folder (⇧⌘K)"
echo "   2. Build the project (⌘B)"
echo ""
echo "📱 Your app is now iOS-focused!"