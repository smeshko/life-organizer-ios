# Quick Start Guide

Get your iOS project up and running in 5 minutes.

## ⚡ Bootstrap Your Project

### Automated Setup (Recommended - 1 minute)

Use the bootstrap script for instant project creation:

```bash
# Navigate to the template directory
cd ~/Developer/iOS/ios-starter-template

# Run the bootstrap script (creates project in ~/Developer/iOS/)
./bootstrap.sh MyAwesomeApp

# Or specify a custom location
./bootstrap.sh MyAwesomeApp ~/Projects
./bootstrap.sh MyAwesomeApp .  # Current directory
```

**Done!** Your project is ready. Follow the on-screen instructions to:
1. Create the Xcode project
2. Build and run
3. Start coding!

### Manual Setup (Alternative - 5 minutes)

If you prefer to do it manually:

#### Step 1: Copy Template (30 seconds)

```bash
# Navigate to your projects directory
cd ~/Developer/iOS

# Copy the template
cp -R ios-starter-template my-awesome-app

# Navigate to your new project
cd my-awesome-app
```

#### Step 2: Customize Names (2 minutes)

```bash
# Set your project name
PROJECT_NAME="MyAwesomeApp"
PROJECT_KIT="${PROJECT_NAME}Kit"

# Replace placeholders in all files
find . -type f \( -name "*.swift" -o -name "*.md" -o -name "*.json" \) -exec sed -i '' "s/LifeOrganizeriOS/$PROJECT_NAME/g" {} +
find . -type f \( -name "*.swift" -o -name "*.md" -o -name "*.json" \) -exec sed -i '' "s/LifeOrganizeriOSKit/$PROJECT_KIT/g" {} +
find . -type f \( -name "*.swift" -o -name "*.md" -o -name "*.json" \) -exec sed -i '' "s/LifeOrganizeriOS/$PROJECT_NAME/g" {} +

# Rename directories
mv LifeOrganizeriOS "$PROJECT_NAME"
mv LifeOrganizeriOSKit "$PROJECT_KIT"

echo "✅ Project customized as $PROJECT_NAME"
```

#### Step 3: Create Xcode Project (2 minutes)

**Option A: New Xcode Project (Recommended)**

1. Open Xcode
2. File → New → Project
3. Choose **iOS** → **App**
4. Product Name: `MyAwesomeApp`
5. Interface: **SwiftUI**
6. Life Cycle: **SwiftUI App**
7. Save in your project directory

8. Add the Swift Package:
   - File → Add Package Dependencies
   - Click "Add Local..."
   - Select the `MyAwesomeAppKit` folder
   - Click "Add Package"

**Option B: Command Line (Faster)**

```bash
# Create basic Xcode project structure
cd $PROJECT_KIT
swift package init --type library

# Generate Xcode project
swift package generate-xcodeproj

# Open in Xcode
open *.xcodeproj
```

#### Step 4: Initialize Git (30 seconds)

```bash
git init
git add .
git commit -m "feat: initialize $PROJECT_NAME from ios-starter-template"

# Optional: Connect to remote repository
# git remote add origin https://github.com/yourusername/$PROJECT_NAME.git
# git push -u origin main
```

#### Step 5: Build and Run (30 seconds)

```bash
# Build the project
xcodebuild build -scheme MyAwesomeApp

# Or in Xcode:
# - Press ⌘+B to build
# - Press ⌘+R to run on simulator
```

## 🎯 Your First Feature

### Create Your First Feature (5 minutes)

1. **Open in Claude Code (or your IDE)**:
   ```bash
   # If using Claude Code
   code .
   ```

2. **Use the ios-feature-creator skill**:
   ```
   Create a new feature called "Welcome" that shows a welcome screen
   ```

   Or manually:
   ```bash
   # Create feature structure
   mkdir -p $PROJECT_KIT/Sources/Features/WelcomeFeature/{Data,Domain,Infrastructure,Presentation}/Views

   # Follow the feature-creation-template.md in docs/development/
   ```

3. **Add to Package.swift**:
   ```swift
   .library(name: "WelcomeFeature", targets: ["WelcomeFeature"]),

   // In targets:
   .feature("WelcomeFeature"),
   ```

4. **Build and test**:
   ```bash
   xcodebuild build -scheme MyAwesomeApp
   ```

## 📚 Next Steps

### Recommended Reading Order

1. **[README.md](README.md)** - Complete overview and architecture
2. **[Setup Guide](docs/development/setup-guide.md)** - Detailed environment setup
3. **[Feature Template](docs/development/feature-creation-template.md)** - Build features
4. **[Service Template](docs/development/service-creation-template.md)** - Create services
5. **[Testing Guide](docs/development/service-test-creation-template.md)** - Write tests

### Common First Tasks

#### Add a Network Service

```bash
# Use ios-service-creator skill in Claude Code
# Or follow docs/development/service-creation-template.md
```

#### Add Persistence

```swift
// The template includes GRDB for SQLite persistence
// Follow service-creation-template.md to create PersistenceService
```

#### Configure App Settings

Edit `$PROJECT_NAME/Info.plist`:
- Add camera usage description (if needed)
- Configure URL schemes
- Set display name

#### Setup CI/CD

Create `.github/workflows/ci.yml`:
```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: xcodebuild build -scheme MyAwesomeApp
      - name: Test
        run: xcodebuild test -scheme MyAwesomeApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## 🔧 Troubleshooting

### Common Issues

**Issue**: `No such module 'ComposableArchitecture'`
```bash
# Solution: Reset package caches
# In Xcode: File → Packages → Reset Package Caches
```

**Issue**: Build fails with Swift 6 errors
```bash
# Solution: Check Xcode version (need 16.2+)
xcode-select --version
```

**Issue**: Simulator not found
```bash
# Solution: List available simulators
xcrun simctl list devices

# Create new simulator if needed
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro"
```

## 🚀 Ready to Build!

You now have a complete, production-ready iOS project structure with:

- ✅ TCA for state management
- ✅ Feature-scoped architecture
- ✅ Service layer with DI
- ✅ Comprehensive templates
- ✅ Claude Code integration
- ✅ Testing infrastructure

**Start building something amazing!** 🎉

---

**Need Help?**

- Check [README.md](README.md) for complete documentation
- Review templates in [docs/development/](docs/development/)
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow

**Pro Tips:**

1. Use Claude Code skills for faster development
2. Follow the templates strictly for consistency
3. Write tests as you build features
4. Commit frequently with clear messages
5. Read the architecture docs to understand patterns

Happy coding! 🚀
