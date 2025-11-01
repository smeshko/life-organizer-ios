---
name: ios-build
description: Build and test the project-rulebook-ios Xcode project using xcodebuild. This skill should be used when users request to build, compile, or test the iOS project. It handles correct simulator destination configuration to avoid provisioning profile errors.
---

# iOS Build

## Overview

Build and test the project-rulebook-ios Xcode project. This skill provides a build script that automatically configures the correct simulator destination to avoid provisioning profile errors.

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

Default configuration: iPhone 16e, iOS 26.0

### Run Tests

```bash
.claude/skills/ios-build/scripts/build.sh --test
```

### Clean and Build

```bash
.claude/skills/ios-build/scripts/build.sh --clean
```

### Custom Simulator

```bash
.claude/skills/ios-build/scripts/build.sh --simulator "iPhone 17 Pro" --ios-version "26.0"
```

## Build Script Options

```
.claude/skills/ios-build/scripts/build.sh [OPTIONS]

Options:
  --test              Run tests instead of building
  --clean             Clean before building
  --simulator NAME    Specify simulator (default: iPhone 16e)
  --ios-version VER   Specify iOS version (default: 26.0)
```

## Key Information

**Scheme:** project-rulebook-ios
**Default Destination:** iPhone 16e, iOS 26.0
**Build Timeout:** 5 minutes (300000ms)

## Additional Resources

When the build script is insufficient or manual xcodebuild commands are needed, refer to:

- `references/xcodebuild-manual.md` - Detailed xcodebuild commands, simulator list, troubleshooting, and advanced options

**Note:** Always specify a simulator destination when using xcodebuild directly to avoid provisioning profile errors.
