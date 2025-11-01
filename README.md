# iOS Starter Template

A production-ready iOS project template based on The Composable Architecture (TCA), Swift 6, and modern iOS development best practices.

## 🎯 Overview

This template provides a complete, opinionated foundation for building robust, scalable iOS applications. It's derived from the architecture patterns and practices refined in the project-rulebook-ios codebase, offering:

- **Feature-Scoped Architecture**: Self-contained, testable feature modules
- **TCA Integration**: The Composable Architecture for predictable state management
- **Service Layer**: Clean, protocol-based services with dependency injection
- **Comprehensive Testing**: Full test infrastructure with mocks and helpers
- **Claude Code Integration**: AI-assisted development with custom skills
- **Documentation**: Complete templates and guides for rapid development

## 🏗️ Architecture Overview

```
LifeOrganizeriOS/
├── .claude/                           # Claude Code configuration
│   ├── CLAUDE.md                      # Project-specific AI instructions
│   ├── settings.local.json           # Permission settings
│   └── skills/                       # Custom Claude skills
│       ├── ios-build/                # Build and test automation
│       ├── ios-feature-creator/      # Feature scaffolding
│       ├── ios-service-creator/      # Service generation
│       └── ios-service-test-creator/ # Test generation
├── docs/                              # Documentation
│   ├── analysis/                     # Codebase analysis
│   ├── architecture/                  # Architecture decisions
│   ├── design/                        # Design documents
│   ├── development/                   # Development templates ⭐
│   │   ├── feature-creation-template.md
│   │   ├── service-creation-template.md
│   │   ├── service-test-creation-template.md
│   │   ├── setup-guide.md
│   │   └── tca-navigation-template.md
│   ├── documentation/                 # External docs references
│   ├── planning/                      # Planning and roadmaps
│   ├── product/                       # Product requirements
│   ├── testing/                       # Testing strategy
│   └── temp/                          # Temporary documents
├── LifeOrganizeriOSKit/                  # Swift Package (business logic)
│   ├── Package.swift                  # Package manifest
│   ├── Sources/                       # Source code
│   │   ├── Entities/                  # Domain models
│   │   ├── Shared/                    # Shared utilities
│   │   ├── Framework/                 # Core framework
│   │   ├── CoreUI/                    # UI components
│   │   ├── Services/                  # Service implementations
│   │   └── Features/                  # TCA feature modules
│   └── Tests/                         # Test suites
└── LifeOrganizeriOS/                 # iOS app target
    ├── LifeOrganizeriOSApp.swift               # App entry point
    ├── Assets.xcassets/               # Assets and icons
    └── Info.plist                     # App configuration
```

## 🚀 Quick Start

### Prerequisites

- macOS 14.0+ (Sonoma) or later
- Xcode 16.2+ with iOS 18.0+ SDK
- Git 2.30+
- Basic understanding of Swift, SwiftUI, and TCA

### Bootstrap Your Project (Automated - Recommended)

Use the included bootstrap script for automatic project setup:

```bash
# Navigate to the template directory
cd ~/Developer/iOS/ios-starter-template

# Run the bootstrap script with your project name
./bootstrap.sh MyAwesomeApp

# Or specify a custom destination
./bootstrap.sh MyAwesomeApp ~/Projects
./bootstrap.sh MyAwesomeApp .  # Current directory
```

The bootstrap script will automatically:
- ✅ Copy all template files
- ✅ Replace all placeholders with your project name
- ✅ Rename directories appropriately
- ✅ Initialize git repository with initial commit
- ✅ Verify project structure
- ✅ Test Swift package build
- ✅ Provide next steps for Xcode project creation

**That's it!** Your project is ready in seconds. Follow the on-screen instructions to complete the setup.

### Manual Bootstrap (Alternative)

If you prefer manual setup:

1. **Clone the template**:
   ```bash
   cd ~/Developer/iOS
   cp -R ios-starter-template LifeOrganizeriOS
   cd LifeOrganizeriOS
   ```

2. **Customize the project**:
   ```bash
   # Replace placeholders with your project name
   find . -type f -name "*.swift" -o -name "*.md" -o -name "*.json" | \
       xargs sed -i '' 's/LifeOrganizeriOS/YourProjectName/g'

   find . -type f -name "*.swift" -o -name "*.md" -o -name "*.json" | \
       xargs sed -i '' 's/LifeOrganizeriOSKit/YourProjectKit/g'
   ```

3. **Rename directories**:
   ```bash
   mv LifeOrganizeriOS YourProjectName
   mv LifeOrganizeriOSKit YourProjectKit
   ```

4. **Create Xcode project**:
   ```bash
   # Option 1: Using Swift Package Manager
   cd YourProjectKit
   swift package generate-xcodeproj

   # Option 2: Create new Xcode project
   # - Open Xcode
   # - File → New → Project
   # - Choose iOS App template
   # - Add YourProjectKit as a local package dependency
   ```

5. **Initialize git repository**:
   ```bash
   git init
   git add .
   git commit -m "feat: initialize project from ios-starter-template"
   ```

6. **Build and run**:
   ```bash
   open YourProjectName.xcodeproj
   # Press ⌘+B to build
   # Press ⌘+R to run on simulator
   ```

## 📚 Documentation

### Essential Guides

- **[Setup Guide](docs/development/setup-guide.md)**: Complete development environment setup
- **[Feature Creation](docs/development/feature-creation-template.md)**: Step-by-step feature development
- **[Service Creation](docs/development/service-creation-template.md)**: Service layer implementation
- **[Service Testing](docs/development/service-test-creation-template.md)**: Comprehensive testing guide
- **[TCA Navigation](docs/development/tca-navigation-template.md)**: Navigation patterns in TCA

### Architecture Principles

#### 1. Feature-Scoped Architecture

Features are self-contained modules with clear boundaries:

```
YourFeature/
├── Data/                    # Data layer
│   ├── DTOs/               # API data transfer objects
│   ├── DataSources/        # Local and remote data sources
│   └── Repositories/       # Data coordination
├── Domain/                  # Business logic
│   ├── Errors/             # Feature-specific errors
│   └── Protocols/          # Repository contracts
├── Infrastructure/          # Supporting infrastructure
│   ├── Analytics/          # Analytics tracking
│   └── Mocks/              # Test doubles
└── Presentation/            # UI layer
    ├── YourFeature.swift   # TCA reducer
    └── Views/              # SwiftUI views
```

#### 2. Service Layer Pattern

Services follow a consistent Interface/Live/Mock structure:

```
YourService/
├── Interface/
│   └── YourServiceProtocol.swift       # Protocol definition
├── Live/
│   └── YourService.swift               # Production implementation
├── Mock/
│   └── MockYourService.swift           # Test implementation
└── YourServiceDependency.swift         # TCA dependency registration
```

#### 3. TCA State Management

The Composable Architecture provides:

- **Predictable State**: Unidirectional data flow
- **Composable Reducers**: Modular state management
- **Effect Management**: Structured concurrency
- **Testability**: TestStore for comprehensive testing

Example reducer:

```swift
@Reducer
public struct MyFeature {
    @ObservableState
    public struct State: Equatable {
        var isLoading = false
        var items: [Item] = []
    }

    public enum Action {
        case onAppear
        case itemsResponse(TaskResult<[Item]>)
    }

    @Dependency(\.apiClient) var apiClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.itemsResponse(
                        await TaskResult { try await apiClient.fetchItems() }
                    ))
                }
            case .itemsResponse(.success(let items)):
                state.isLoading = false
                state.items = items
                return .none
            case .itemsResponse(.failure):
                state.isLoading = false
                return .none
            }
        }
    }
}
```

## 🛠️ Development Workflow

### Creating a New Feature

1. **Use the ios-feature-creator skill** (recommended):
   ```
   # In Claude Code, use the skill:
   /skill ios-feature-creator
   ```

2. **Or follow the manual template**:
   - Read [Feature Creation Template](docs/development/feature-creation-template.md)
   - Create directory structure
   - Implement following the pattern
   - Add to Package.swift
   - Write tests

### Creating a New Service

1. **Use the ios-service-creator skill** (recommended):
   ```
   # In Claude Code, use the skill:
   /skill ios-service-creator
   ```

2. **Or follow the manual template**:
   - Read [Service Creation Template](docs/development/service-creation-template.md)
   - Implement protocol interface
   - Create live implementation
   - Create mock for testing
   - Register with TCA dependencies

### Writing Tests

1. **Use the ios-service-test-creator skill** (recommended):
   ```
   # In Claude Code, use the skill:
   /skill ios-service-test-creator
   ```

2. **Or follow the manual template**:
   - Read [Service Test Template](docs/development/service-test-creation-template.md)
   - Create test infrastructure (mocks, fixtures)
   - Write method-specific tests
   - Test error handling
   - Verify coverage

### Building and Testing

```bash
# Build the project
xcodebuild build -scheme YourProjectName

# Run tests
xcodebuild test -scheme YourProjectName -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or use the ios-build skill in Claude Code
/skill ios-build
```

## 🎨 Claude Code Integration

This template includes custom Claude Code skills for AI-assisted development:

### Available Skills

#### ios-build
Build and test the project using xcodebuild with proper configuration.

**Usage**: Invoke when you need to build or run tests.

#### ios-feature-creator
Create new TCA features following Feature-Scoped Architecture patterns.

**Usage**: Invoke when implementing new features.

#### ios-service-creator
Implement new services following the Interface/Live/Mock pattern.

**Usage**: Invoke when creating infrastructure services.

#### ios-service-test-creator
Write comprehensive tests for services with proper organization.

**Usage**: Invoke when testing service implementations.

### Configuration

Claude Code is pre-configured in `.claude/`:

- **CLAUDE.md**: Project-specific instructions for AI assistance
- **settings.local.json**: Permission settings for safe automation
- **skills/**: Custom skills for common development tasks

## 📦 Dependencies

This template uses carefully selected, production-proven dependencies:

- **[TCA](https://github.com/pointfreeco/swift-composable-architecture)** (1.21.0+): The Composable Architecture
- **[swift-dependencies](https://github.com/pointfreeco/swift-dependencies)** (1.9.0+): Dependency injection
- **[GRDB](https://github.com/groue/GRDB.swift)** (6.0.0+): SQLite database (optional, for persistence)
- **[swift-sharing](https://github.com/pointfreeco/swift-sharing)** (1.0.5+): Shared observable state

All dependencies are managed via Swift Package Manager and specified in `Package.swift`.

## 🧪 Testing Philosophy

### Test Coverage Requirements

- **Unit Tests**: All public methods in features and services
- **Integration Tests**: Critical user flows
- **TCA Tests**: All reducer logic with comprehensive assertions

### Test Organization

```
Tests/
├── YourFeatureTests/
│   ├── Domain/              # Business logic tests
│   ├── Infrastructure/      # Mock and helper tests
│   ├── Integration/         # Integration tests
│   └── Presentation/        # Reducer tests
└── YourServiceTests/
    ├── Helpers/             # Test infrastructure
    ├── {Method}Tests.swift  # Method-specific tests
    └── ErrorHandlingTests.swift
```

### Example Test

```swift
@Test("Feature loads data on appear")
func featureLoadsDataOnAppear() async {
    let store = TestStore(initialState: MyFeature.State()) {
        MyFeature()
    } withDependencies: {
        $0.apiClient = .testValue
    }

    await store.send(.onAppear) {
        $0.isLoading = true
    }

    await store.receive(.itemsResponse(.success(mockItems))) {
        $0.isLoading = false
        $0.items = mockItems
    }
}
```

## 🔧 Customization

### Modifying Build Settings

Edit `Package.swift` to adjust:

- **iOS deployment target**: Change `.iOS(.v18)` to your minimum version
- **Swift settings**: Modify `BuildSettings.standard` for compiler flags
- **Dependencies**: Add or update package dependencies

### Adding Features

1. Create feature module in `Sources/Features/YourFeature/`
2. Follow [Feature Creation Template](docs/development/feature-creation-template.md)
3. Add to `Package.swift`:

```swift
.library(name: "YourFeature", targets: ["YourFeature"]),

// In targets:
.feature(
    "YourFeature",
    dependencies: ["Entities", "NetworkService"]
),
```

### Adding Services

1. Create service in `Sources/Services/YourService/`
2. Follow [Service Creation Template](docs/development/service-creation-template.md)
3. Add to `Package.swift`:

```swift
.library(name: "YourService", targets: ["YourService"]),

// In targets:
.service(
    "YourService",
    dependencies: ["Framework"]
),
```

## 📈 Best Practices

### Code Organization

- ✅ Keep features self-contained and independent
- ✅ Use protocols for abstraction at service boundaries
- ✅ Inject dependencies via TCA's `@Dependency`
- ✅ Write tests alongside implementation
- ✅ Document public APIs with DocC comments

### TCA Patterns

- ✅ Use `@ObservableState` for state management
- ✅ Model effects with `Effect<Action>`
- ✅ Use `@Presents` for modal presentations
- ✅ Handle errors explicitly in state
- ✅ Test with `TestStore` for predictability

### Performance

- ✅ Use `@Sendable` for concurrent code
- ✅ Leverage Swift 6's strict concurrency
- ✅ Profile with Instruments regularly
- ✅ Optimize image processing with actors
- ✅ Use lazy loading for large data sets

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

Quick checklist:

- [ ] Branch from `staging`
- [ ] Follow commit conventions
- [ ] Write tests for new code
- [ ] Update documentation
- [ ] Create PR to `staging`
- [ ] Request code review

## 📄 License

This template is provided as-is for use in your projects. Customize and adapt as needed for your specific use case.

## 🙏 Acknowledgments

This template is based on architectural patterns and practices from:

- **The Composable Architecture** by Point-Free
- **Swift API Design Guidelines** by Apple
- **Feature-Scoped Architecture** principles
- **project-rulebook-ios** real-world implementation

## 📞 Support

For questions, issues, or suggestions:

1. Check the [documentation](docs/)
2. Review existing [issues](issues)
3. Create a new issue with detailed information
4. Reach out to maintainers

---

**Happy Building!** 🎉

This template provides a solid foundation for modern iOS development. Start building your next great app with confidence.

*Last updated: 2025-10-30*
*Template version: 1.0.0*
