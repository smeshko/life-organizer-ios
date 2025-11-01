# [Your Project Name] Development Guidelines

Last updated: [Current Date]

## Active Technologies
- Swift 6.0 (Package.swift swift-tools-version: 6.0)
- TCA (The Composable Architecture) 1.21.0+
- SwiftUI for declarative UI
- GRDB for local persistence (if needed)

## Project Structure
```
Sources/
├── Entities/           # Domain models
├── Shared/             # Shared utilities
├── Framework/          # Core framework (DI, config, errors)
├── CoreUI/             # Reusable UI components
├── Services/           # Service layer (network, persistence, etc.)
└── Features/           # TCA feature modules
Tests/
├── {Feature}Tests/     # Feature-specific tests
└── {Service}Tests/     # Service-specific tests
```

## Commands
# Add your custom commands here

## Code Style
Swift 6.0: Follow standard conventions
- Use strict concurrency checking
- Follow TCA patterns for state management
- Feature-scoped architecture for modules

## Development Workflow

### Creating New Features
Use the `ios-feature-creator` skill or follow the template in `docs/development/feature-creation-template.md`

### Creating New Services
Use the `ios-service-creator` skill or follow the template in `docs/development/service-creation-template.md`

### Writing Tests
Use the `ios-service-test-creator` skill or follow the template in `docs/development/service-test-creation-template.md`

### Building the Project
Use the `ios-build` skill or run:
```bash
xcodebuild build -scheme LifeOrganizeriOS
```

## Architecture Principles

### Feature-Scoped Architecture
- Features are self-contained modules
- Each feature has its own domain, data, and presentation layers
- Dependencies are injected via TCA's dependency system

### Service Layer
- Services follow Interface/Live/Mock pattern
- All services are registered with TCA's dependency system
- Protocol-based for testability

### Entity-First Design
- Domain entities are the single source of truth
- Entities are shared across layers
- DTOs only when necessary for API mapping

## Recent Changes
- [Add your project changes here as you build]

<!-- MANUAL ADDITIONS START -->

## Claude Skills Available

### ios-build
**Purpose**: Build and test the Xcode project using xcodebuild
**Usage**: Use when building or running tests

### ios-feature-creator
**Purpose**: Create new TCA features following the Feature-Scoped Architecture
**Usage**: Use when implementing new features

### ios-service-creator
**Purpose**: Implement new services following the service architecture pattern
**Usage**: Use when creating infrastructure services

### ios-service-test-creator
**Purpose**: Write comprehensive tests for services
**Usage**: Use when testing service implementations

<!-- MANUAL ADDITIONS END -->
