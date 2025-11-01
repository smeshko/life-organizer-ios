# Contributing to [Your Project Name]

Welcome! This guide will help you understand our development process, coding standards, and how to submit contributions effectively.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Style Guidelines](#code-style-guidelines)
- [Architecture Principles](#architecture-principles)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Issue Reporting](#issue-reporting)

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **macOS 14.0+** (Sonoma) with Xcode 16.2+
- **iOS 18.0+ SDK** for development and testing
- **Git 2.30+** for version control
- Basic understanding of **Swift**, **SwiftUI**, and **The Composable Architecture (TCA)**

### Setup Instructions

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/LifeOrganizeriOS.git
   cd LifeOrganizeriOS
   ```

2. **Set Up Development Environment**
   ```bash
   open LifeOrganizeriOS.xcodeproj
   # Dependencies are automatically resolved via Swift Package Manager
   ```

3. **Verify Setup**
   - Build the project: `⌘+B`
   - Run tests: `⌘+U`
   - Run on simulator: `⌘+R`

4. **Review Documentation**
   - Read [Setup Guide](docs/development/setup-guide.md)
   - Study [Feature Creation Template](docs/development/feature-creation-template.md)
   - Study [Service Creation Template](docs/development/service-creation-template.md)

## Development Workflow

### Branch Strategy

We use **GitFlow** with these branch types:

```
main            # Production-ready code
├── staging     # Integration branch for testing
├── feature/    # New features and enhancements
├── bugfix/     # Bug fixes
├── hotfix/     # Emergency production fixes
└── docs/       # Documentation updates
```

### Creating a Feature Branch

```bash
# Always branch from staging
git checkout staging
git pull origin staging

# Create feature branch
git checkout -b feature/your-feature-name
```

### Branch Naming Conventions

- **Features**: `feature/short-description` (e.g., `feature/offline-sync`)
- **Bug Fixes**: `bugfix/issue-description` (e.g., `bugfix/camera-crash-ios17`)
- **Documentation**: `docs/documentation-update` (e.g., `docs/api-documentation`)
- **Refactoring**: `refactor/code-improvement` (e.g., `refactor/networking-layer`)

### Commit Standards

We follow **Conventional Commits** specification:

```bash
# Format: type(scope): description
git commit -m "feat(feature-name): add new functionality"
git commit -m "fix(service-name): resolve memory leak"
git commit -m "docs(api): update endpoint documentation"
git commit -m "test(feature): add comprehensive TCA reducer tests"
```

**Commit Types**:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

### Commit Message Guidelines

```
<type>(<scope>): <subject>

<body>

<footer>
```

Example:
```
feat(network): add retry logic for failed requests

- Implement exponential backoff strategy
- Add maximum retry limit configuration
- Update error handling to support retries

Closes #123
```

## Code Style Guidelines

### Swift Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use descriptive names for functions and variables
- Prefer clarity over brevity
- Use type inference when it improves readability
- Document public APIs with DocC-style comments

### SwiftUI Conventions

```swift
// ✅ Good: Clear view hierarchy
struct ContentView: View {
    let store: StoreOf<Feature>

    var body: some View {
        VStack(spacing: 16) {
            HeaderView()
            ContentBodyView()
            FooterView()
        }
    }
}

// ❌ Avoid: Overly nested views
struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    // Too deeply nested...
                }
            }
        }
    }
}
```

### TCA Patterns

```swift
// ✅ Good: Well-organized reducer
@Reducer
public struct MyFeature {
    @ObservableState
    public struct State: Equatable { }

    public enum Action {
        case onAppear
        case response(TaskResult<Data>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // Effect logic
                }
            case .response(.success(let data)):
                return .none
            }
        }
    }
}
```

## Architecture Principles

### Feature-Scoped Architecture

Every feature follows this structure:

```
YourFeature/
├── Data/
│   ├── DTOs/
│   ├── DataSources/
│   └── Repositories/
├── Domain/
│   ├── Errors/
│   └── Protocols/
├── Infrastructure/
│   ├── Analytics/
│   └── Mocks/
└── Presentation/
    ├── YourFeature.swift
    └── Views/
```

See [Feature Creation Template](docs/development/feature-creation-template.md) for details.

### Service Pattern

All services follow Interface/Live/Mock pattern:

```
YourService/
├── Interface/
│   └── YourServiceProtocol.swift
├── Live/
│   └── YourService.swift
├── Mock/
│   └── MockYourService.swift
└── YourServiceDependency.swift
```

See [Service Creation Template](docs/development/service-creation-template.md) for details.

## Testing Requirements

### Test Coverage

- **Unit Tests**: All public methods in features and services
- **Integration Tests**: Critical user flows
- **TCA Tests**: All reducer logic with TestStore

### Writing Tests

```swift
@Test("Feature handles user action correctly")
func featureHandlesUserAction() async {
    let store = TestStore(initialState: MyFeature.State()) {
        MyFeature()
    } withDependencies: {
        $0.apiClient = .testValue
    }

    await store.send(.buttonTapped) {
        $0.isLoading = true
    }

    await store.receive(.response(.success(data))) {
        $0.isLoading = false
        $0.result = data
    }
}
```

See [Service Test Creation Template](docs/development/service-test-creation-template.md) for comprehensive testing guidance.

## Pull Request Process

### Before Creating a PR

1. **Update from staging**:
   ```bash
   git checkout staging
   git pull origin staging
   git checkout your-feature-branch
   git rebase staging
   ```

2. **Run all tests**: Ensure all tests pass
3. **Update documentation**: Keep docs current with changes
4. **Self-review**: Review your own changes first

### Creating the PR

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR against `staging`** (not `main`)

3. **Fill out PR template** with:
   - Description of changes
   - Testing performed
   - Screenshots (if UI changes)
   - Breaking changes (if any)

4. **Request review** from team members

### PR Requirements

- [ ] All tests pass
- [ ] No merge conflicts
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Self-reviewed for quality

## Code Review Guidelines

### As a Reviewer

- **Be constructive**: Provide actionable feedback
- **Ask questions**: Understand the "why" behind changes
- **Approve promptly**: Don't block unnecessarily
- **Test locally**: If significant changes

### As an Author

- **Respond to feedback**: Address all comments
- **Be open**: Consider alternative approaches
- **Update accordingly**: Make requested changes
- **Thank reviewers**: Appreciate their time

## Issue Reporting

### Creating Issues

Use issue templates and include:

```markdown
## Description
[Clear description of the issue]

## Steps to Reproduce
1. Step one
2. Step two
3. ...

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- iOS version:
- Device:
- App version:

## Screenshots
[If applicable]
```

### Issue Labels

- `bug`: Something isn't working
- `feature`: New feature request
- `documentation`: Documentation updates
- `enhancement`: Improvement to existing feature
- `question`: Further information requested

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on what's best for the project
- Show empathy towards others

### Getting Help

- Check existing [documentation](docs/)
- Search [existing issues](issues)
- Ask in discussions
- Reach out to maintainers

---

Thank you for contributing to [Your Project Name]! Your efforts help make this project better for everyone.
