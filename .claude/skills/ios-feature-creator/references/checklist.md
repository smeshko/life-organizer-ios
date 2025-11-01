# Architecture Compliance Checklist

Before considering your feature complete, verify the following requirements are met.

## Feature-Scoped Architecture

- [ ] DTOs are in `Sources/Features/{Feature}Feature/Data/DTOs/`
- [ ] Mappers are in `Sources/Features/{Feature}Feature/Infrastructure/`
- [ ] No global abstractions unless shared across multiple features
- [ ] Feature can evolve independently

## Pragmatic Simplification

- [ ] Only create abstractions that add meaningful value
- [ ] Direct usage of existing services via `@Dependency`
- [ ] No translation layers that just shuffle fields
- [ ] Minimal, focused interfaces

## Dependency-Driven Design

- [ ] All dependencies injected via `@Dependency` wrapper
- [ ] Repository registered with `DependencyKey`
- [ ] Protocol interfaces where abstraction adds value
- [ ] Clean separation between interface and implementation

## Entity-First Domain Modeling

- [ ] Domain entity is the single source of truth
- [ ] Codable entities serve multiple purposes
- [ ] Business logic embedded in entities where appropriate
- [ ] No artificial data/domain boundaries

## Quality Standards

- [ ] All async functions marked properly
- [ ] Actor-based concurrent design where needed
- [ ] Comprehensive error handling with meaningful messages
- [ ] Analytics tracking for user interactions
- [ ] Mock implementations for testing
- [ ] Basic unit tests written

## Package Integration

- [ ] Feature added to Package.swift products and targets
- [ ] Dependencies correctly specified
- [ ] Test target created and configured
- [ ] No circular dependencies

---

# Common Patterns & Best Practices

## Repository Pattern Implementation

- **Local-first approach**: Always try local data first, fall back to remote
- **Automatic caching**: Remote fetches automatically save to local storage
- **Graceful sync**: Sync operations don't throw errors, just log failures
- **Consistent naming**: Use domain terminology (`gameTitle` not `gameId`)

## Error Handling Strategy

- **Feature-specific errors**: Create dedicated error enums for each feature
- **Meaningful messages**: Provide clear error descriptions and recovery suggestions
- **User-friendly presentation**: Transform technical errors into actionable user messages
- **Analytics integration**: Track errors for debugging and product insights

## TCA Patterns

- **State separation**: Keep UI state separate from business data
- **Effect composition**: Use `TaskResult` for async operations
- **Presentation management**: Use `@Presents` for alerts and sheets
- **Delegate pattern**: Communicate with parent features via delegate actions

## Testing Strategy

- **Mock repositories**: Create simple mocks that mirror real interfaces
- **TestStore usage**: Use TCA's TestStore for predictable testing
- **Dependency injection**: Replace real dependencies with test doubles
- **Focused scenarios**: Test specific user flows and edge cases
