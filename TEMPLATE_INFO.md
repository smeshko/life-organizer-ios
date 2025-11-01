# iOS Starter Template - Information

**Version**: 1.0.0
**Created**: 2025-10-30
**Last Updated**: 2025-10-30

## Overview

This is a production-ready iOS project template based on The Composable Architecture (TCA), Swift 6, and modern iOS development best practices. It's designed to give you a complete, opinionated foundation for building robust, scalable iOS applications.

## What's Included

### 📂 Directory Structure

```
ios-starter-template/
├── bootstrap.sh                        # Fully automated setup ⭐
├── README.md                           # Complete documentation
├── QUICKSTART.md                       # 5-minute guide
├── CONTRIBUTING.md                     # Contribution guidelines
├── TEMPLATE_INFO.md                    # This file
├── .gitignore                          # iOS-specific gitignore
├── .swiftlint.yml                     # Code quality configuration
│
├── .claude/                            # Claude Code Integration
│   ├── CLAUDE.md                      # AI assistant instructions
│   ├── settings.local.json            # Permission settings
│   └── skills/                        # 4 custom Claude skills
│       ├── ios-build/
│       ├── ios-feature-creator/
│       ├── ios-service-creator/
│       └── ios-service-test-creator/
│
├── scripts/                            # Utility Scripts
│   ├── approve-macros.sh              # Pre-approve TCA macros
│   └── generate-xcodeproj.sh          # Regenerate Xcode project ⭐
│
├── docs/                               # Comprehensive Documentation
│   ├── analysis/
│   ├── architecture/
│   ├── design/
│   ├── development/                   # 5 Essential Templates ⭐
│   │   ├── feature-creation-template.md
│   │   ├── service-creation-template.md
│   │   ├── service-test-creation-template.md
│   │   ├── setup-guide.md
│   │   └── tca-navigation-template.md
│   ├── documentation/
│   ├── planning/
│   ├── product/
│   ├── testing/
│   └── temp/
│
├── LifeOrganizeriOS.xcodeproj/       # Pre-configured Xcode Project ⭐
│   ├── project.pbxproj                # Template with placeholder UUIDs
│   ├── project.xcworkspace/
│   └── xcshareddata/xcschemes/
│
├── LifeOrganizeriOSKit/                   # Swift Package (Embedded)
│   ├── Package.swift                  # Pre-configured with TCA, GRDB
│   ├── Sources/
│   │   ├── AppFeature/               # Main app feature (TCA) ⭐
│   │   ├── Entities/                 # Domain models
│   │   ├── Shared/                   # Utilities
│   │   ├── Framework/                # Core framework + AppError.swift
│   │   └── CoreUI/                   # UI components
│   └── Tests/
│       └── FrameworkTests/
│
└── LifeOrganizeriOS/                  # iOS App Target
    ├── LifeOrganizeriOSApp.swift               # Entry point using AppFeature
    └── Assets.xcassets/
```

## Quick Start

### Using the Bootstrap Script (Recommended)

The easiest way to create a new project:

```bash
# Navigate to template
cd ~/Developer/iOS/ios-starter-template

# Create your project
./bootstrap.sh MyAwesomeApp

# Or specify custom location
./bootstrap.sh MyAwesomeApp ~/Projects
```

The script automatically:
- ✅ Copies all template files
- ✅ Replaces placeholders with your project name
- ✅ Renames directories (app, kit, xcodeproj)
- ✅ Generates unique UUIDs for Xcode project
- ✅ Configures embedded package reference
- ✅ Initializes git repository
- ✅ Pre-approves TCA macros
- ✅ Resolves package dependencies
- ✅ Opens project in Xcode automatically
- ✅ Ready to build and run immediately!

### Manual Setup

See [QUICKSTART.md](QUICKSTART.md) for manual setup instructions.

## Features

### Architecture

- **TCA (The Composable Architecture)**: Elm-inspired state management
- **Feature-Scoped Architecture**: Self-contained, testable modules
- **Service Layer**: Clean Interface/Live/Mock pattern
- **Swift 6**: Strict concurrency, modern patterns
- **Entity-First Design**: Domain models as single source of truth

### Dependencies

All managed via Swift Package Manager:
- **TCA** 1.21.0+ - The Composable Architecture
- **swift-dependencies** 1.9.0+ - Dependency injection
- **GRDB** 6.0.0+ - SQLite database
- **swift-sharing** 1.0.5+ - Shared observable state

### Developer Tools

- **4 Claude Code Skills**: AI-assisted development
  - ios-build: Build and test automation
  - ios-feature-creator: Feature scaffolding
  - ios-service-creator: Service generation
  - ios-service-test-creator: Test generation

- **Comprehensive Templates**:
  - Feature creation (973 lines)
  - Service creation (524 lines)
  - Service testing (486 lines)
  - TCA navigation (509 lines)
  - Setup guide (693 lines)

### Code Quality

- SwiftLint configuration included
- Swift 6 strict concurrency
- Comprehensive error handling
- Mock implementations for all services
- Testing infrastructure

## Documentation

### Essential Files

1. **[README.md](README.md)** - Complete overview and architecture guide
2. **[QUICKSTART.md](QUICKSTART.md)** - 5-minute bootstrap guide
3. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development workflow and standards
4. **[bootstrap.sh](bootstrap.sh)** - Automated project setup script

### Development Templates

Located in `docs/development/`:

1. **feature-creation-template.md** - Complete guide for creating TCA features
2. **service-creation-template.md** - Service layer implementation guide
3. **service-test-creation-template.md** - Comprehensive testing strategies
4. **tca-navigation-template.md** - Navigation patterns in TCA
5. **setup-guide.md** - Development environment setup

## Usage

### Creating a New Project

```bash
# Using bootstrap script (recommended)
./bootstrap.sh MyProjectName

# Or manual setup
cp -R ios-starter-template my-project
cd my-project
# Follow QUICKSTART.md for manual steps
```

### Project Name Requirements

- Must start with uppercase letter (e.g., MyApp)
- Can only contain letters and numbers
- No spaces or special characters
- Follow Swift naming conventions

### Valid Examples

- ✅ MyAwesomeApp
- ✅ TravelBuddy
- ✅ FitnessTracker2024
- ❌ myApp (doesn't start with uppercase)
- ❌ My-App (contains hyphen)
- ❌ My App (contains space)

## Customization

### Modifying the Template

Before creating new projects, you can customize:

1. **Package.swift**: Change iOS version, dependencies
2. **Build Settings**: Modify compiler flags
3. **Claude Skills**: Adjust AI assistance behavior
4. **Templates**: Update development guides
5. **.swiftlint.yml**: Change code style rules

### After Creating a Project

Once bootstrapped, customize your project:

1. Update app assets in `Assets.xcassets`
2. Modify `Info.plist` for permissions
3. Add features using templates
4. Create services as needed
5. Configure build settings in Xcode

## Architecture Benefits

✅ **Modular**: Features are self-contained and independent
✅ **Testable**: Mock implementations for all dependencies
✅ **Type-Safe**: Swift 6 strict concurrency throughout
✅ **Scalable**: Grows from small app to large codebase
✅ **Maintainable**: Clear patterns and documentation
✅ **Modern**: Latest iOS/Swift best practices

## Common Workflows

### Adding a Feature

```bash
# Use Claude Code skill
/skill ios-feature-creator

# Or follow template
open docs/development/feature-creation-template.md
```

### Adding a Service

```bash
# Use Claude Code skill
/skill ios-service-creator

# Or follow template
open docs/development/service-creation-template.md
```

### Writing Tests

```bash
# Use Claude Code skill
/skill ios-service-test-creator

# Or follow template
open docs/development/service-test-creation-template.md
```

## Utility Scripts

### Regenerating Xcode Project

If your Xcode project becomes corrupted or you need to regenerate it:

```bash
cd /path/to/your/project
./scripts/generate-xcodeproj.sh
```

This will:
- Backup your existing xcodeproj
- Generate a fresh project with unique UUIDs
- Reconfigure the embedded kit reference
- Create new schemes

**When to use**:
- After major structural changes
- If xcodeproj becomes corrupted
- When migrating Xcode versions
- If package references break

## Troubleshooting

### Bootstrap Script Issues

**Problem**: Permission denied
```bash
# Solution: Make script executable
chmod +x bootstrap.sh
```

**Problem**: Project already exists
```bash
# Solution: Remove existing directory or use different name
rm -rf ~/Developer/iOS/MyApp
./bootstrap.sh MyApp
```

### Build Issues

**Problem**: Module 'ComposableArchitecture' not found
```bash
# Solution: Reset package caches in Xcode
# File → Packages → Reset Package Caches
```

**Problem**: Swift 6 errors
```bash
# Solution: Update to Xcode 16.2+
xcode-select --version
```

**Problem**: Xcode project corrupted
```bash
# Solution: Regenerate the xcodeproj
./scripts/generate-xcodeproj.sh
```

## Version History

### 1.1.0 (2025-10-31)
- Added pre-configured xcodeproj template
- Fully automated project setup (including Xcode opening)
- Embedded kit structure (matches rulebook pattern)
- AppFeature module with TCA reducer
- UUID generation for unique project IDs
- Utility script for xcodeproj regeneration
- Removed umbrella module pattern
- Individual feature imports only

### 1.0.0 (2025-10-30)
- Initial release
- TCA architecture with Feature-Scoped pattern
- 4 Claude Code skills
- 5 comprehensive templates
- Automated bootstrap script
- Complete documentation

## Credits

This template is based on:
- **The Composable Architecture** by Point-Free
- **Swift API Design Guidelines** by Apple
- **Feature-Scoped Architecture** principles
- Real-world production iOS app patterns

## License

This template is provided as-is for use in your projects. Customize and adapt as needed.

## Support

- **Documentation**: Check README.md and QUICKSTART.md
- **Templates**: Review docs/development/ guides
- **Issues**: Create detailed bug reports with environment info
- **Questions**: Consult the comprehensive documentation first

## Next Steps

After reading this file:

1. Read [QUICKSTART.md](QUICKSTART.md) to create your first project
2. Review [README.md](README.md) for architecture details
3. Check [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow
4. Run `./bootstrap.sh --help` to see script options
5. Start building! 🚀

---

**Happy coding!** This template provides everything you need for production-quality iOS development.

*Template created from project-rulebook-ios architectural analysis*
*Includes patterns refined through real-world production use*
