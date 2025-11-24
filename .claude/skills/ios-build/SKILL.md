---
name: ios-build
description: Build and test the LifeOrganizeriOS Xcode project using xcodebuild. This skill should be used when users request to build, compile, or test the iOS project. It handles correct simulator destination configuration to avoid provisioning profile errors.
---

# iOS Build

## Overview

Build and test the LifeOrganizeriOS Xcode project. This skill provides a token-efficient build script that:
- Captures build output and shows only relevant information
- On success: displays "BUILD SUCCEEDED" with duration
- On failure: displays only error messages
- Automatically configures the correct simulator destination

## When to Use

Use this skill when users request to:
- Build the iOS project
- Run tests for the iOS project
- Clean and rebuild the project
- Verify compilation success

## Quick Start

### Build the Project

```bash
.claude/skills/ios-build/scripts/build.sh
```

Output on success:
```
Building LifeOrganizeriOS (build)
Destination: iPhone 16e, iOS 18.3.1
Running xcodebuild...
BUILD SUCCEEDED (45s)
```

### Run Tests

```bash
.claude/skills/ios-build/scripts/build.sh --test
```

### Clean and Build

```bash
.claude/skills/ios-build/scripts/build.sh --clean
```

### Full Output (Debugging)

Use `--verbose` when you need to see the complete xcodebuild output:

```bash
.claude/skills/ios-build/scripts/build.sh --verbose
```

## Build Script Options

```
.claude/skills/ios-build/scripts/build.sh [OPTIONS]

Options:
  --test              Run tests instead of building
  --clean             Clean before building
  --verbose           Show full xcodebuild output (for debugging)
  --simulator NAME    Specify simulator (default: iPhone 16e)
  --ios-version VER   Specify iOS version (default: 18.3.1)
```

## Key Information

**Scheme:** LifeOrganizeriOS
**Default Destination:** iPhone 16e, iOS 18.3.1
**Build Timeout:** 5 minutes (300000ms)

## Additional Resources

When the build script is insufficient or manual xcodebuild commands are needed, refer to:

- `references/xcodebuild-manual.md` - Detailed xcodebuild commands, simulator list, troubleshooting, and advanced options

**Note:** Always specify a simulator destination when using xcodebuild directly to avoid provisioning profile errors.
