# Claude Code Skills

This template includes 4 custom Claude Code skills for iOS development:

## Available Skills

### 1. ios-build
**Purpose**: Build and test the Xcode project using xcodebuild with proper simulator configuration.

**When to use**: Building the project or running tests.

**Features**:
- Automatic simulator destination configuration
- Proper error handling for provisioning profiles
- Test execution with detailed output

### 2. ios-feature-creator
**Purpose**: Create new TCA features following Feature-Scoped Architecture patterns.

**When to use**: Implementing new features in your app.

**Features**:
- Complete feature directory structure creation
- TCA reducer scaffolding with State/Action/Reducer
- Repository pattern implementation
- Mock implementations for testing
- Package.swift integration

### 3. ios-service-creator
**Purpose**: Implement new services following the Interface/Live/Mock pattern.

**When to use**: Creating infrastructure services (networking, persistence, etc.).

**Features**:
- Protocol-based service interfaces
- Live implementation scaffolding
- Mock implementations for testing
- TCA dependency registration
- Error handling patterns

### 4. ios-service-test-creator
**Purpose**: Write comprehensive tests for services with proper organization.

**When to use**: Testing service implementations.

**Features**:
- Test infrastructure setup (mocks, fixtures)
- Method-specific test files
- Error handling tests
- Thread-safe mock implementations
- Swift 6 Sendable compliance

## Using Skills

In Claude Code, invoke skills with:
```
/skill ios-build
/skill ios-feature-creator
/skill ios-service-creator
/skill ios-service-test-creator
```

Or let Claude Code automatically suggest the appropriate skill based on your request.

## Customizing Skills

Each skill has its own directory with:
- `SKILL.md` - Skill definition and instructions
- `references/` - Reference documentation and templates
- `scripts/` - Shell scripts for automation (if applicable)

You can customize these files to match your project's specific needs.
