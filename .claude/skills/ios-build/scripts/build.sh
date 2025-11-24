#!/bin/bash
# Build script for LifeOrganizeriOS
# Automatically selects an appropriate iOS Simulator destination
# Token-efficient: captures output and shows only relevant info by default

SCHEME="LifeOrganizeriOS"

# Default simulator - prefer newer iOS versions
SIMULATOR="iPhone 16e"
IOS_VERSION="18.3.1"

# Parse command line arguments
BUILD_TYPE="build"
CLEAN=false
VERBOSE=false

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
    --verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--test] [--clean] [--verbose] [--simulator NAME] [--ios-version VERSION]"
      exit 1
      ;;
  esac
done

DESTINATION="platform=iOS Simulator,name=$SIMULATOR,OS=$IOS_VERSION"

echo "Building $SCHEME ($BUILD_TYPE)"
echo "Destination: $SIMULATOR, iOS $IOS_VERSION"

# Clean if requested
if [ "$CLEAN" = true ]; then
  echo "Cleaning..."
  xcodebuild clean -scheme "$SCHEME" -quiet 2>/dev/null
fi

# Create temp file for output capture
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

START_TIME=$(date +%s)

if [ "$VERBOSE" = true ]; then
  # Verbose mode: stream output directly
  xcodebuild "$BUILD_TYPE" -scheme "$SCHEME" -destination "$DESTINATION"
  EXIT_CODE=$?
else
  # Quiet mode: capture output, show only errors
  echo "Running xcodebuild..."
  xcodebuild "$BUILD_TYPE" -scheme "$SCHEME" -destination "$DESTINATION" > "$TEMP_OUTPUT" 2>&1
  EXIT_CODE=$?
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 0 ]; then
  if [ "$BUILD_TYPE" = "test" ]; then
    # Extract test summary for test runs
    TEST_SUMMARY=$(grep -E "Test Suite.*passed|Test Suite.*failed|Executed [0-9]+ test" "$TEMP_OUTPUT" | tail -3)
    if [ -n "$TEST_SUMMARY" ]; then
      echo ""
      echo "$TEST_SUMMARY"
    fi
    echo ""
    echo "TESTS PASSED (${DURATION}s)"
  else
    echo "BUILD SUCCEEDED (${DURATION}s)"
  fi
else
  echo ""
  echo "BUILD FAILED"
  echo ""
  # Show only error lines (deduplicated)
  grep -E "error:|fatal error:" "$TEMP_OUTPUT" | sort -u
  echo ""
  echo "Use --verbose for full output"
  exit 1
fi
