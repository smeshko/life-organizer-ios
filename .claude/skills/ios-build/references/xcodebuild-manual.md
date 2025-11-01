# Manual xcodebuild Commands Reference

This document provides detailed xcodebuild command examples, troubleshooting steps, and simulator information for when the build script is insufficient or manual control is needed.

## Direct xcodebuild Commands

### Build the Project

```bash
xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
```

**Important:** Always specify a `-destination` parameter when building. Building without a destination will fail with provisioning profile errors.

### Run Tests

```bash
xcodebuild test -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
```

### Clean Build

```bash
xcodebuild clean -scheme project-rulebook-ios
```

### Clean and Build

```bash
xcodebuild clean -scheme project-rulebook-ios
xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
```

### Use a Different Simulator

```bash
xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0'
```

## Available Simulators

### iOS 26.0 (Latest)
- iPhone 16e
- iPhone 17
- iPhone 17 Pro
- iPhone 17 Pro Max
- iPhone Air
- iPad (A16)
- iPad Air 11-inch (M3)
- iPad Air 13-inch (M3)
- iPad Pro 11-inch (M4)
- iPad Pro 13-inch (M4)
- iPad mini (A17 Pro)

### iOS 18.3.1
- iPhone 16
- iPhone 16e
- iPad (A16)
- iPad Air 11-inch (M3)
- iPad Air 13-inch (M3)

### List All Available Simulators

To see all available simulators in your environment:

```bash
xcrun simctl list devices available
```

## Troubleshooting

### Provisioning Profile Errors

**Error:**
```
error: Provisioning profile "iOS Team Provisioning Profile: *" doesn't include the currently selected device
```

**Cause:** This occurs when building without specifying a simulator destination. xcodebuild defaults to building for "My Mac" which requires proper provisioning.

**Solution:** Always use the `-destination` parameter with an iOS Simulator:
```bash
xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
```

### Simulator Not Found

**Error:**
```
error: Unable to find a device matching the provided destination specifier
```

**Solutions:**

1. **Check available simulators:**
   ```bash
   xcrun simctl list devices available
   ```

2. **Verify the simulator name and OS version match exactly** (case-sensitive)

3. **Use the default known-working configuration:**
   ```bash
   xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
   ```

4. **Boot the simulator first** (sometimes helps):
   ```bash
   xcrun simctl boot "iPhone 16e"
   ```

### Build Timeout

The build commands have a 5-minute timeout (300000ms). If builds consistently timeout:

1. **Clean derived data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/project-rulebook-ios-*
   ```

2. **Run a clean build:**
   ```bash
   xcodebuild clean -scheme project-rulebook-ios
   xcodebuild build -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.0'
   ```

3. **Check system resources:**
   - Verify sufficient disk space
   - Check Activity Monitor for resource constraints
   - Close other Xcode instances

4. **Increase timeout** (if calling from scripts):
   - Use `--timeout 600000` (10 minutes) for Bash tool calls

### Scheme Not Found

**Error:**
```
error: Scheme 'project-rulebook-ios' not found
```

**Solutions:**

1. **Ensure you're in the project directory:**
   ```bash
   cd /Users/A1E6E98/Developer/iOS/project-rulebook-ios
   ```

2. **List available schemes:**
   ```bash
   xcodebuild -list
   ```

3. **Specify the project explicitly:**
   ```bash
   xcodebuild -project project-rulebook-ios.xcodeproj -scheme project-rulebook-ios -destination '...'
   ```

## Project Information

### Build Configuration

- **Scheme:** project-rulebook-ios
- **Project:** project-rulebook-ios.xcodeproj
- **Default destination:** iPhone 16e, iOS 26.0
- **Total targets:** 76 (includes app, local packages, and dependencies)

### Local Packages

- **rulebook-kit** - Contains all feature modules and services
  - AppFeature
  - MainNavigationFeature
  - RulesFeature, LibraryFeature
  - Services: NetworkService, PersistenceService, ImageProcessingService, etc.
  - UI: CoreUI, OnboardingFeature, PhotoFeature, SettingsFeature

### Key Dependencies

- Swift Composable Architecture (TCA)
- GRDB (database)
- swift-navigation
- swift-dependencies
- swift-perception
- swift-sharing

## Advanced xcodebuild Options

### Build for Specific Configuration

```bash
xcodebuild build -scheme project-rulebook-ios -configuration Debug -destination '...'
xcodebuild build -scheme project-rulebook-ios -configuration Release -destination '...'
```

### Show Build Settings

```bash
xcodebuild -showBuildSettings -scheme project-rulebook-ios
```

### Build to Specific Derived Data Location

```bash
xcodebuild build -scheme project-rulebook-ios -destination '...' -derivedDataPath ./build
```

### Run Specific Test Target

```bash
xcodebuild test -scheme project-rulebook-ios -destination '...' -only-testing:TargetName/TestClassName/testMethodName
```

### Skip Testing

```bash
xcodebuild build -scheme project-rulebook-ios -destination '...' -skipTesting:TargetName
```
