---
name: iOS Service Creator
description: Implement new services in the Rulebook iOS project following the service architecture pattern. This skill should be used when creating new infrastructure services, implementing protocols with live and mock implementations, or adding dependency-injected services. Uses Swift 6, async/await, and TCA dependency system.
---

# iOS Service Creator

Implement new services following the Rulebook iOS project's service architecture pattern with protocol-based design, live implementations, mocks for testing, and TCA dependency registration.

## When to Use

Use this skill when:
- Creating new infrastructure services (networking, persistence, camera, analytics, etc.)
- Implementing services that will be used across multiple features
- Building services that require testable mock implementations
- Adding services to the TCA dependency system

## Service Architecture

All services follow this structure:
```
YourService/
├── Interface/
│   └── YourServiceProtocol.swift       # Protocol definition
├── Live/
│   └── YourService.swift               # Production implementation
├── Mock/
│   └── MockYourService.swift           # Testing implementation
└── YourServiceDependency.swift         # TCA dependency registration
```

## Quick Start

### 1. Define Service Requirements

Before creating files, document:
- **Service Purpose**: What functionality does this service provide?
- **Method Signatures**: What operations are needed?
- **Dependencies**: What external services does it need?
- **Error Cases**: What errors can occur?

### 2. Create Directory Structure

Use the helper script to create the standard structure:

```bash
scripts/create_service_structure.sh {ServiceName}
```

This creates the four-file service structure.

### 3. Follow Implementation Steps

Refer to `references/service-implementation.md` for the detailed step-by-step guide covering:

1. Create the protocol interface with comprehensive documentation
2. Implement the live service with proper error handling
3. Create the mock implementation with test helpers
4. Register with TCA dependencies
5. Define service-specific errors (if needed)
6. Integrate with features
7. Write tests

### 4. Use Code Templates

All code templates are in `references/code-templates.md`:
- Protocol interface pattern
- Live service implementation
- Mock service with test helpers
- Dependency registration
- Error definitions
- Feature integration examples

### 5. Verify Implementation

Before completing, check against `references/checklist.md` to ensure:
- Protocol definition quality
- Live implementation standards
- Mock implementation features
- Dependency registration
- Integration and testing

### 6. Avoid Common Mistakes

Review `references/anti-patterns.md` for patterns to avoid:
- Over-abstraction
- Complex state management
- Stream over-engineering
- Global scope creep
- Speculative interfaces

## Key Principles

- **Protocol-Based**: Define clear protocol interfaces for abstraction
- **Sendable**: All protocols and implementations must be `Sendable` for Swift 6
- **Async-First**: Use async/await consistently throughout
- **Error-Transparent**: Transform external errors to `AppError` types
- **Test-Friendly**: Provide comprehensive mocks with test helpers
- **Dependency-Injected**: Register with TCA's `DependencyValues`

## Design Philosophy

Services should be:
- **Focused**: Single responsibility, clear scope
- **Simple**: Only essential complexity, avoid over-engineering
- **Pragmatic**: Build what's needed now, not what might be needed
- **Essential**: Every method must be actively used by at least one feature
