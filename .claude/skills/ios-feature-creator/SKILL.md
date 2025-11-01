---
name: iOS Feature Creator
description: Create new TCA features in the Rulebook iOS project following Feature-Scoped Architecture. This skill should be used when implementing new features, building TCA reducers, or creating feature modules with repository patterns. Uses Swift 6, TCA, and async/await patterns.
---

# iOS Feature Creator

Create new TCA (The Composable Architecture) features following the Rulebook iOS project's Feature-Scoped Architecture principles.

## When to Use

Use this skill when:
- Implementing a new feature module with TCA
- Creating features with data layer (repository, data sources, DTOs)
- Building features that require local and remote data synchronization
- Setting up feature-specific error handling and analytics

## Quick Start

### 1. Define Feature Requirements

Before creating files, document:
- **Feature Purpose**: What business problem does this solve?
- **Data Requirements**: What entities/data does this feature manage?
- **External Dependencies**: What existing services will it use?
- **User Interactions**: What actions can users perform?

### 2. Create Directory Structure

Use the helper script to create the standard structure:

```bash
scripts/create_feature_structure.sh {FeatureName}
```

This creates:
```
Sources/Features/{FeatureName}Feature/
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
    └── Views/
```

### 3. Follow Implementation Steps

Refer to `references/feature-structure.md` for the detailed step-by-step implementation guide covering:

1. Feature-scoped entity creation
2. DTO definition
3. Domain error types
4. Protocol definitions (repository, data sources)
5. Entity mapper implementation
6. Data source implementations (local & remote)
7. Repository implementation
8. Mock repository for testing
9. Analytics service
10. TCA feature reducer
11. API endpoints (if needed)
12. Package.swift updates
13. Basic tests

### 4. Use Code Templates

All code templates are in `references/code-templates.md`:
- Entity structure
- DTO structure
- Error enum
- Protocol definitions
- Mapper pattern
- Data sources (local/remote)
- Repository with dependency injection
- Mock repository
- Analytics service
- TCA reducer
- API endpoints

### 5. Verify Compliance

Before completing, check against `references/checklist.md` to ensure:
- Feature-scoped architecture compliance
- Pragmatic simplification principles
- Dependency-driven design
- Entity-first domain modeling
- Quality standards (async, actor, error handling, analytics, tests)
- Package integration

### 6. Avoid Common Mistakes

Review `references/anti-patterns.md` for patterns to avoid:
- Global abstraction creep
- Unnecessary translation layers
- Protocol over-engineering
- Complex state management

## Key Principles

- **Feature-Scoped**: DTOs and infrastructure stay within feature boundaries
- **Pragmatic**: Only create abstractions that add meaningful value
- **Dependency-Driven**: Use `@Dependency` for all service injections
- **Entity-First**: Domain entity is the single source of truth
- **Local-First**: Repository pattern tries local data first, falls back to remote

## Architecture

The project follows a Feature-Scoped Architecture where each feature is self-contained with its own:
- Data layer (DTOs, mappers, data sources)
- Domain layer (protocols, errors)
- Infrastructure (mocks, analytics, endpoints)
- Presentation layer (TCA reducers, views)

Features depend on shared services (NetworkService, PersistenceService, AnalyticsService) via dependency injection but maintain their own feature-specific implementations.
