#!/bin/bash

# Clean build script for WorkoutTracker
echo "Cleaning WorkoutTracker project..."

# Remove any potential derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/WorkoutTracker-*

# Remove any build artifacts in project directory
find . -name "build" -type d -exec rm -rf {} + 2>/dev/null
find . -name "*.o" -exec rm -f {} + 2>/dev/null
find . -name "*.dSYM" -type d -exec rm -rf {} + 2>/dev/null

# Clean the project using xcodebuild
xcodebuild clean -project WorkoutTracker.xcodeproj -alltargets

echo "Clean complete. You can now build the project in Xcode."
echo "If the error persists, please:"
echo "1. Close Xcode completely"
echo "2. Run this script"
echo "3. Reopen Xcode"
echo "4. Build the project"