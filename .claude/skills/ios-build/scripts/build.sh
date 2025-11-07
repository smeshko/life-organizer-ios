#!/bin/bash
# Build script for LifeOrganizeriOS
# Automatically selects an appropriate iOS Simulator destination

set -e

SCHEME="LifeOrganizeriOS"

# Default simulator - prefer newer iOS versions
SIMULATOR="iPhone 16e"
IOS_VERSION="18.3.1"

# Parse command line arguments
BUILD_TYPE="build"
CLEAN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --test)
      BUILD_TYPE="test"
      shift
      ;;
    --clean)
      CLEAN=true
      shift
      ;;
    --simulator)
      SIMULATOR="$2"
      shift 2
      ;;
    --ios-version)
      IOS_VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--test] [--clean] [--simulator NAME] [--ios-version VERSION]"
      exit 1
      ;;
  esac
done

DESTINATION="platform=iOS Simulator,name=$SIMULATOR,OS=$IOS_VERSION"

echo "🏗️  Building $SCHEME"
echo "📱 Destination: $DESTINATION"
echo ""

if [ "$CLEAN" = true ]; then
  echo "🧹 Cleaning build artifacts..."
  xcodebuild clean -scheme "$SCHEME"
  echo ""
fi

echo "▶️  Running xcodebuild $BUILD_TYPE..."
xcodebuild "$BUILD_TYPE" -scheme "$SCHEME" -destination "$DESTINATION"

echo ""
echo "✅ Build completed successfully!"
