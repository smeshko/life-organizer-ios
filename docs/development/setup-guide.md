# Developer Setup Guide

## Overview
This guide provides comprehensive setup instructions for developing project-rulebook-ios and contributing to the BoardMate transformation.

## Prerequisites

### System Requirements
- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 16.2+ with iOS 15.0+ SDK support
- **Swift**: 6.0+ (included with Xcode)
- **Git**: 2.30+ for version control

### Hardware Requirements
- **Mac**: Intel or Apple Silicon Mac with 16GB+ RAM recommended
- **Storage**: 10GB+ free space for Xcode, simulators, and project
- **iOS Device**: iPhone/iPad running iOS 15+ for device testing (optional)

## Project Structure Overview

```
project-rulebook-ios/
├── project-rulebook-ios/          # Main iOS app target
│   ├── RulebookApp.swift          # App entry point
│   ├── Assets.xcassets/           # App assets and icons
│   └── Info.plist                 # App configuration
├── rulebook-kit/                   # Business logic Swift Package
│   ├── Package.swift              # Package dependencies and targets
│   ├── Sources/                   # Source code modules
│   └── Tests/                     # Test suites
└── docs/                          # Project documentation
    ├── analysis/                  # Codebase analysis
    ├── architecture/              # Architecture documentation  
    ├── development/               # Development guides (this file)
    ├── planning/                  # Implementation plans
    └── testing/                   # Testing strategies
```

## Initial Setup

### 1. Repository Setup

#### Clone Repository
```bash
git clone https://github.com/your-org/project-rulebook-ios.git
cd project-rulebook-ios
```

#### Branch Strategy
```bash
# Main development branch
git checkout staging

# Create feature branch for your work
git checkout -b feature/your-feature-name
```

### 2. Xcode Configuration

#### Open Project
```bash
# Open the main Xcode project
open project-rulebook-ios.xcodeproj
```

#### First Build
1. **Select Target**: Choose "project-rulebook-ios" scheme
2. **Select Simulator**: iPhone 15 Pro (iOS 17.0+) or your preferred device
3. **Build**: ⌘+B to build project
4. **Run**: ⌘+R to run the app

#### Dependency Resolution
- Dependencies are automatically resolved via Swift Package Manager
- If issues occur, go to **File → Packages → Reset Package Caches**

### 3. Development Environment Setup

#### Simulators
Install recommended iOS simulators:
- **iOS 15.0**: Minimum supported version testing
- **iOS 17.0**: Primary development target
- **iOS 18.0**: Latest version testing

```bash
# Install via Xcode → Preferences → Platforms
# Or use Simulator.app → Device → Manage Devices
```

#### Code Style Tools (Optional)
```bash
# Install SwiftFormat for code formatting
brew install swiftformat

# Install SwiftLint for code quality
brew install swiftlint
```

## Project Architecture Understanding

### The Composable Architecture (TCA)
The project uses TCA for state management. Key concepts:

#### Reducer Pattern
```swift
@Reducer
struct FeatureReducer {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
    }
    
    enum Action {
        case buttonTapped
        case response(Result<String, Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                state.isLoading = true
                return .run { send in
                    // Async work here
                }
            case .response(.success(let value)):
                state.isLoading = false
                return .none
            }
        }
    }
}
```

#### SwiftUI Integration
```swift
struct FeatureView: View {
    let store: StoreOf<FeatureReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.isLoading {
                    ProgressView()
                }
                
                Button("Tap Me") {
                    viewStore.send(.buttonTapped)
                }
            }
        }
    }
}
```

### Swift Package Manager Structure
The `rulebook-kit` package contains all business logic:

- **Features**: TCA reducers for app functionality
- **Services**: Network, persistence, and external integrations
- **Models**: Domain models and DTOs
- **Utilities**: Shared utilities and extensions

## Development Workflow

### 1. Feature Development Process

#### Before Starting
1. **Review Architecture**: Read relevant docs in `docs/architecture/`
2. **Understand Requirements**: Check implementation plans in `docs/planning/`
3. **Set Up Branch**: Create feature branch from `staging`

#### During Development
1. **Follow TCA Patterns**: Use established patterns for reducers and effects
2. **Write Tests**: Unit tests for reducers, integration tests for services
3. **Update Documentation**: Keep docs current with changes
4. **Regular Commits**: Small, focused commits with clear messages

#### Code Organization
```swift
// Feature structure example
Sources/
├── FeatureX/
│   ├── FeatureXReducer.swift      # TCA reducer
│   ├── Views/
│   │   └── FeatureXView.swift     # SwiftUI views
│   ├── Models/
│   │   └── FeatureXModels.swift   # Feature-specific models
│   └── Services/
│       └── FeatureXService.swift  # External integrations
```

### 2. Testing Strategy

#### Running Tests
```bash
# Run all tests
xcodebuild test -scheme project-rulebook-ios -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'

# Run specific test
xcodebuild test -scheme project-rulebook-ios -only-testing:FeatureXTests/FeatureXReducerTests

# Through Xcode: ⌘+U for all tests, ⌘+Ctrl+U for current test
```

#### Test Types
1. **Unit Tests**: TCA reducer logic, model validation
2. **Integration Tests**: Service interactions, API calls
3. **UI Tests**: User flow validation, accessibility testing

#### Writing TCA Tests
```swift
@Test func testFeatureAction() async {
    let store = TestStore(initialState: FeatureReducer.State()) {
        FeatureReducer()
    } withDependencies: {
        $0.apiClient = .testValue
    }
    
    await store.send(.buttonTapped) {
        $0.isLoading = true
    }
    
    await store.receive(.response(.success("result"))) {
        $0.isLoading = false
        $0.result = "result"
    }
}
```

### 3. Build and Debug

#### Build Configurations
- **Debug**: Development with full debugging, slower performance
- **Release**: Production-optimized build for testing and distribution

#### Common Build Issues
1. **Package Resolution**: Reset package caches if dependencies fail
2. **iOS Version**: Ensure minimum deployment target is iOS 15.0
3. **Signing**: Use automatic signing for development

#### Debugging Tools
- **Xcode Debugger**: Set breakpoints in reducers and view updates
- **TCA Inspector**: Use TCA's built-in state inspection
- **Console Logging**: Use `print()` or proper logging for debugging

### 4. Performance Considerations

#### Image Processing
- Large images are processed in background actors
- Use JPEG compression for network uploads
- Implement proper memory management for image data

#### TCA Performance
- Keep state structures small and efficient
- Use proper effect cancellation
- Implement lazy loading for large data sets

## API Integration

### Backend Services
The app integrates with backend APIs for:
- **Image Analysis**: Game box recognition
- **Rules Summarization**: AI-generated game rules

#### Development Configuration
```swift
// In AppConfiguration.swift
public static let development = AppConfiguration(
    imageAnalysisBaseURL: "https://your-dev-api.ngrok.io",
    rulesBaseURL: "https://your-dev-api.ngrok.io",
    networkTimeout: 30.0,
    imageCompressionQuality: 0.6
)
```

#### Testing with Mock Services
```swift
// Use test dependencies for development
extension APIClient: TestDependencyKey {
    static let testValue = APIClient(
        analyzeImage: { _ in
            ImageAnalysisResponse(guessedTitle: "Test Game")
        }
    )
}
```

## Troubleshooting

### Common Issues

#### 1. Build Failures
```
Error: No such module 'ComposableArchitecture'
```
**Solution**: Reset package caches in Xcode

#### 2. iOS Compatibility
```
Error: 'UIImage' is only available in iOS 16.0 or newer
```
**Solution**: Check iOS deployment target is 15.0, use availability checks

#### 3. TCA State Issues
```
Error: State mutation outside of reducer
```
**Solution**: All state changes must go through reducer actions

#### 4. Camera Permissions
```
Error: Camera access denied
```
**Solution**: Check Info.plist has camera usage descriptions

### Debug Strategies

#### TCA State Debugging
```swift
// Add to reducer for state inspection
.debug() // Logs all actions and state changes

// Custom debug with filtering
.debug("[RulesFeature]", state: \.isLoading, action: .formatted())
```

#### Network Debugging
```swift
// Enable network logging in development
URLSession.shared.configuration.protocolClasses = [NetworkLogger.self]

// Debug specific endpoint issues
print("Request URL: \(endpoint.url?.absoluteString ?? "nil")")
print("Request Headers: \(endpoint.headers)")
```

#### Performance Profiling
- Use Xcode Instruments for memory and performance analysis
- Monitor image processing performance in development
- Check for memory leaks in TCA effects
- Profile GRDB database operations for large datasets

### Advanced Troubleshooting

#### 1. Swift Package Manager Issues

**Problem**: Packages not resolving or building
```
error: package resolution failed
```

**Solutions**:
```bash
# Reset package caches
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build

# In Xcode: File → Packages → Reset Package Caches
# Then: File → Packages → Update to Latest Package Versions
```

**Alternative approach**:
```bash
# Clean and rebuild
xcodebuild clean -scheme project-rulebook-ios
xcodebuild build -scheme project-rulebook-ios
```

#### 2. GRDB Database Issues

**Problem**: Database migration failures
```
GRDB.DatabaseError: database is locked
```

**Solutions**:
```swift
// Add to PersistenceService configuration
var config = Configuration()
config.busyMode = .timeout(30.0)
config.prepareDatabase { db in
    db.execute(sql: "PRAGMA journal_mode=WAL")
}
```

**Database inspection**:
```bash
# Use sqlite3 to inspect database
sqlite3 ~/Library/Developer/CoreSimulator/.../Documents/rules.db
.tables
.schema rules_summary
```

#### 3. TCA Testing Issues

**Problem**: TestStore failures with async operations
```
TestStore.receive(action) was not called
```

**Solutions**:
```swift
@Test func testAsyncAction() async {
    let store = TestStore(initialState: RulesFeature.State(gameTitle: "Test")) {
        RulesFeature()
    } withDependencies: {
        $0.rulesRepository = .testValue
        // Mock all dependencies used in effects
    }
    
    await store.send(.onAppear) {
        $0.isLoading = true
    }
    
    // Wait for async effects to complete
    await store.receive(.rulesResponse(.success(mockRules))) {
        $0.isLoading = false
        $0.gameRules = mockRules
    }
    
    await store.receive(.delegate(.rulesUpdated(mockRules)))
}
```

#### 4. iOS Simulator Performance

**Problem**: Slow simulator performance affecting development

**Solutions**:
```bash
# Reset iOS Simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Use lightweight simulator
# Prefer iPhone 15 Pro over older models for better performance
```

**Simulator optimization**:
- Hardware → Graphics Quality → Decrease for better performance
- Use "Slow Animations" when debugging UI transitions
- Restart simulator periodically during long development sessions

#### 5. Image Processing Issues

**Problem**: Out of memory crashes when processing large images

**Solutions**:
```swift
// Add to ImageProcessingClient
func processImage(_ data: Data) async throws -> ProcessedImage {
    // Limit memory usage
    guard data.count <= 10_485_760 else { // 10MB limit
        throw ImageProcessingError.imageTooLarge
    }
    
    return try await Task.detached(priority: .userInitiated) {
        // Process on background thread
        autoreleasepool {
            // Process image here
        }
    }.value
}
```

**Memory monitoring**:
```swift
// Add to development builds
#if DEBUG
func logMemoryUsage() {
    let info = mach_task_basic_info()
    print("Memory usage: \(info.resident_size / 1024 / 1024) MB")
}
#endif
```

#### 6. Network Configuration Issues

**Problem**: API calls failing in development

**Checklist**:
- [ ] Check network connectivity
- [ ] Verify API endpoint URLs in AppConfiguration
- [ ] Confirm backend services are running
- [ ] Test with curl commands first

```bash
# Test image analysis endpoint
curl -X POST \
  -H "Content-Type: image/jpeg" \
  --data-binary @test-image.jpg \
  https://your-dev-api.ngrok.io/api/rules-generation/game-box-analysis

# Test rules generation endpoint
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"gameTitle":"Monopoly","preferences":{"complexity":"beginner"}}' \
  https://your-dev-api.ngrok.io/api/rules-generation/rules-summary
```

**Network debugging configuration**:
```swift
// Add to AppConfiguration for development
public static let development = AppConfiguration(
    imageAnalysisBaseURL: "https://your-dev-api.ngrok.io",
    rulesBaseURL: "https://your-dev-api.ngrok.io", 
    networkTimeout: 60.0, // Increased for debugging
    logLevel: .debug
)
```

#### 7. Code Signing and Provisioning

**Problem**: Build fails due to signing issues
```
error: Signing for "project-rulebook-ios" requires a development team
```

**Solutions**:
1. **Automatic Signing** (Recommended for development):
   - Select your Apple ID in Xcode → Preferences → Accounts
   - In project settings: Signing & Capabilities → Automatically manage signing
   - Choose your development team

2. **Manual Provisioning**:
   - Create development certificates in Apple Developer Center
   - Download and install provisioning profiles
   - Select specific profile in project settings

#### 8. Build Performance Optimization

**Problem**: Slow build times during development

**Solutions**:
```bash
# Enable build timing in Xcode
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES

# Optimize DerivedData location (SSD storage)
# Xcode → Preferences → Locations → DerivedData → Choose faster drive

# Increase build system performance
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 8
```

**Swift compiler optimizations**:
```swift
// In Package.swift for development
.target(
    name: "YourTarget",
    dependencies: [...],
    swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .define("DEBUG", .when(configuration: .debug))
    ]
)
```

### Environment-Specific Troubleshooting

#### macOS Sonoma (14.0+) Issues

**Problem**: New security restrictions affecting development

**Solutions**:
- Enable Developer Mode: System Settings → Privacy & Security → Developer Mode
- Allow Terminal full disk access for build scripts
- Grant Xcode necessary permissions for simulators and devices

#### Apple Silicon (M1/M2) Specific Issues

**Problem**: Dependency compilation failures on Apple Silicon

**Solutions**:
```bash
# Force x86_64 architecture for problematic dependencies
arch -x86_64 xcodebuild build -scheme project-rulebook-ios

# Or set architecture in Xcode build settings
ARCHS = arm64 x86_64
VALID_ARCHS = arm64 x86_64
```

#### iOS 18.0+ Development Issues

**Problem**: New iOS features causing compatibility issues

**Solutions**:
- Update to latest Xcode version (16.2+)
- Review iOS 18.0 API changes and deprecations
- Test on multiple iOS versions (15.0 minimum, 18.0 latest)
- Use availability checks for new APIs:

```swift
if #available(iOS 18.0, *) {
    // Use iOS 18+ specific APIs
} else {
    // Fallback for earlier versions
}
```

### Getting Help

#### Internal Resources
1. **Check existing documentation** in `docs/` folder
2. **Review recent commits** for similar issues
3. **Search project issues** on GitHub
4. **Check ADRs** in `docs/architecture/` for architectural decisions

#### External Resources
1. **TCA Community**: Point-Free Slack channel
2. **Swift Forums**: developer.swift.org
3. **Stack Overflow**: Tag with `swift`, `swiftui`, `the-composable-architecture`
4. **Apple Developer Forums**: developer.apple.com/forums

#### Creating Bug Reports

When reporting issues, include:
```markdown
## Environment
- macOS version: 
- Xcode version:
- iOS deployment target:
- Device/Simulator:

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior

## Actual Behavior

## Console Output
```

Attach relevant logs, crash reports, and screenshots when possible.

## Contributing Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use consistent naming conventions
- Add documentation comments for public APIs
- Keep functions focused and small

### Commit Messages
```
feat: add image processing optimization

- Implement background processing actor
- Add JPEG compression for uploads  
- Reduce memory usage by 60%

Closes #123
```

### Pull Request Process
1. **Create PR** against `staging` branch
2. **Add Description**: Explain changes and testing performed
3. **Request Review**: Get code review approval
4. **Merge**: Squash and merge to maintain clean history

### Documentation Updates
- Update relevant documentation when making changes
- Add architectural decision records for major changes
- Keep API documentation current with code changes

## Useful Resources

### Project Documentation
- **Architecture Overview**: `docs/architecture/current-state-analysis.md`
- **BoardMate Vision**: `docs/architecture/boardmate-vision.md`
- **Testing Strategy**: `docs/testing/testing-strategy.md`
- **Migration Plans**: `docs/planning/`

### External Resources
- **TCA Documentation**: [Point-Free TCA](https://pointfreeco.github.io/swift-composable-architecture/)
- **Swift Documentation**: [Swift.org](https://swift.org/documentation/)
- **iOS Development**: [Apple Developer Documentation](https://developer.apple.com/documentation/)

### Community
- **Point-Free**: TCA discussions and examples
- **Swift Forums**: General Swift development questions
- **iOS Dev Community**: Platform-specific discussions

---
*Guide Version: 2.0*
*Updated: 2025-08-14*
*Next Review: After Phase 2 completion*

*Major updates in v2.0: Comprehensive troubleshooting section, advanced debugging techniques, environment-specific issues, and detailed problem-solving guides.*