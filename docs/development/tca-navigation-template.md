# TCA Navigation Template Guide

This document provides comprehensive templates and patterns for implementing navigation in The Composable Architecture (TCA), based on analysis of the Rulebook iOS project's navigation patterns.

## Overview

TCA navigation follows a declarative pattern where navigation state is managed in the feature's state, and navigation actions are handled through specific TCA mechanisms:

- **System Alerts**: Using `@Presents` with `AlertState<Action.Alert>`  
- **Modal Presentation**: Using `@Presents` with `Destination.State` enum
- **Navigation Stack**: Using `NavigationStack` with programmatic navigation

## 1. System Alerts Pattern

### Feature State Setup

```swift
@Reducer
public struct MyFeature {
    @ObservableState
    public struct State {
        // Alert presentation state
        @Presents public var alert: AlertState<Action.Alert>?
        
        // Other state properties...
        public var errorMessage: String?
        public var showingErrorAlert: Bool = false  // Alternative pattern
        
        public init() {}
    }
    
    public enum Action {
        // Alert actions (TCA managed)
        case alert(PresentationAction<Alert>)
        
        // Your feature actions
        case someErrorOccurred(Error)
        case retryButtonTapped
        
        // Nested alert actions
        public enum Alert {
            case retry
            case dismiss
        }
    }
}
```

### Feature Reducer Implementation

```swift
public var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case let .someErrorOccurred(error):
            // Show alert with TCA's AlertState
            state.alert = AlertState {
                TextState("Error")
            } actions: {
                ButtonState(action: .retry) {
                    TextState("Retry")
                }
                ButtonState(role: .cancel, action: .dismiss) {
                    TextState("Cancel")
                }
            } message: {
                TextState(error.localizedDescription)
            }
            return .none
            
        case .alert(.presented(.retry)):
            // Handle retry action
            state.alert = nil
            return .send(.retryButtonTapped)
            
        case .alert(.presented(.dismiss)):
            // Handle dismiss action
            state.alert = nil
            return .none
            
        case .alert:
            return .none
        }
    }
    .ifLet(\.$alert, action: \.alert)  // Essential: Connect alert state
}
```

### View Integration

```swift
public struct MyView: View {
    let store: StoreOf<MyFeature>
    
    public var body: some View {
        // Your view content...
        Text("Content")
            .alert($store.scope(state: \.alert, action: \.alert))
    }
}
```

### Alternative Boolean Alert Pattern

For simpler alerts without complex actions:

```swift
// In State
public var showingErrorAlert: Bool = false
public var errorMessage: String?

// In View
.alert(
    "Error",
    isPresented: Binding(
        get: { store.showingErrorAlert },
        set: { _ in store.send(.errorAlertDismissed) }
    )
) {
    Button("Retry") {
        store.send(.retryOperation)
    }
    Button("OK") {
        store.send(.errorAlertDismissed)
    }
} message: {
    Text(store.errorMessage ?? "An error occurred")
}
```

## 2. Modal Presentation Pattern

### Destination Enum Setup

```swift
@Reducer
public struct MainFeature {
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        
        public init() {}
    }
    
    public enum Action {
        case presentModalTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    public enum Destination {
        case modalFeature(ModalFeature)
        case anotherModal(AnotherFeature)
    }
}
```

### Feature Reducer with Modal Logic

```swift
public var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case .presentModalTapped:
            state.destination = .modalFeature(ModalFeature.State())
            return .none
            
        case .destination(.presented(.modalFeature(.delegate(.didComplete)))):
            // Handle modal completion
            state.destination = nil
            return .none
            
        case .destination(.presented(.modalFeature(.delegate(.didDismiss)))):
            // Handle modal dismissal
            state.destination = nil
            return .none
            
        case .destination:
            return .none
        }
    }
    .ifLet(\.$destination, action: \.destination)
}
```

### View Integration with Different Modal Types

```swift
public struct MainView: View {
    let store: StoreOf<MainFeature>
    
    public var body: some View {
        NavigationView {
            // Your content...
            Button("Present Modal") {
                store.send(.presentModalTapped)
            }
        }
        // Full-screen modal
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.modalFeature, 
                action: \.destination.modalFeature
            )
        ) { modalStore in
            ModalView(store: modalStore)
        }
        // Sheet modal
        .sheet(
            item: $store.scope(
                state: \.destination?.anotherModal,
                action: \.destination.anotherModal
            )
        ) { anotherModalStore in
            AnotherModalView(store: anotherModalStore)
        }
    }
}
```

## 3. Navigation Stack Pattern

### Navigation State Setup

```swift
@Reducer
public struct NavigationFeature {
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        
        public init() {}
    }
    
    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case pushDetailTapped(String)
    }
    
    @Reducer
    public struct Path {
        @ObservableState
        public enum State {
            case detail(DetailFeature.State)
            case settings(SettingsFeature.State)
        }
        
        public enum Action {
            case detail(DetailFeature.Action)
            case settings(SettingsFeature.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) {
                DetailFeature()
            }
            Scope(state: \.settings, action: \.settings) {
                SettingsFeature()
            }
        }
    }
}
```

### Navigation Reducer Implementation

```swift
public var body: some ReducerOf<Self> {
    Reduce { state, action in
        switch action {
        case let .pushDetailTapped(id):
            state.path.append(.detail(DetailFeature.State(id: id)))
            return .none
            
        case .path(.element(id: _, action: .detail(.delegate(.dismiss)))):
            // Handle programmatic navigation
            state.path.removeLast()
            return .none
            
        case .path:
            return .none
        }
    }
    .forEach(\.path, action: \.path) {
        Path()
    }
}
```

### Navigation View Implementation

```swift
public struct NavigationView: View {
    let store: StoreOf<NavigationFeature>
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            // Root view content
            List {
                Button("Push Detail") {
                    store.send(.pushDetailTapped("example-id"))
                }
            }
            .navigationTitle("Root")
        } destination: { store in
            // Handle different destination types
            switch store.case {
            case let .detail(store):
                DetailView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            }
        }
    }
}
```

## 4. Complex Navigation Flow (Real-world Example)

Based on the MainNavigationFeature from the Rulebook app:

```swift
@Reducer
public struct MainNavigationFeature {
    @ObservableState
    public struct State {
        public var selectedTab: Tab = .library
        public var library = LibraryFeature.State()
        
        @Presents var destination: Destination.State?
        var isProcessingImage: Bool = false
        
        public enum Tab: String, Hashable {
            case library = "Library"
            case settings = "Settings"
        }
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case tabSelected(State.Tab)
        case library(LibraryFeature.Action)
        case cameraButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case imageAnalysisResponse(Result<String, Error>)
    }
    
    @Reducer
    public enum Destination {
        case cameraModal(PhotoFeature)
        case rulesModal(RulesFeature)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.library, action: \.library) {
            LibraryFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .cameraButtonTapped:
                state.destination = .cameraModal(PhotoFeature.State())
                return .none
                
            case .destination(.presented(.cameraModal(.delegate(.didCaptureImage(let imageData))))):
                state.destination = nil
                state.isProcessingImage = true
                
                return .run { send in
                    // Process image...
                    let result = try await analyzeImage(imageData)
                    await send(.imageAnalysisResponse(.success(result)))
                } catch: { error, send in
                    await send(.imageAnalysisResponse(.failure(error)))
                }
                
            case .imageAnalysisResponse(.success(let gameTitle)):
                state.destination = .rulesModal(RulesFeature.State(gameTitle: gameTitle))
                state.isProcessingImage = false
                return .none
                
            case .destination(.presented(.rulesModal(.delegate(.dismiss)))):
                state.destination = nil
                return .none
                
            // ... other cases
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

## 5. Best Practices & Common Patterns

### Error Handling in Navigation

```swift
// Show error alerts during navigation flows
case .imageAnalysisResponse(.failure(let error)):
    state.isProcessingImage = false
    state.destination = nil
    state.alert = AlertState {
        TextState("Analysis Failed")
    } actions: {
        ButtonState(action: .retry) {
            TextState("Try Again")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState(error.localizedDescription)
    }
    return .none
```

### Loading States During Navigation

```swift
// Show loading during navigation transitions
case .startImageProcessing:
    state.isProcessingImage = true
    state.destination = nil  // Dismiss current modal
    
    return .run { send in
        // Long-running operation
        let result = try await processImage()
        await send(.processingComplete(result))
    }
```

### Delegate Communication Pattern

```swift
// Child feature delegate
public enum Delegate {
    case didComplete(Result)
    case didCancel
    case didDismiss
}

// Parent handling
case .destination(.presented(.childFeature(.delegate(.didComplete(let result))))):
    state.destination = nil
    // Handle the result
    return handleResult(result, state: &state)
```

### Multiple Modal Types

```swift
@Reducer
public enum Destination {
    case cameraModal(CameraFeature)
    case rulesModal(RulesFeature)  
    case settingsModal(SettingsFeature)
    case confirmationAlert(ConfirmationFeature)
}

// In View
.fullScreenCover(item: $store.scope(state: \.destination?.cameraModal, action: \.destination.cameraModal)) { store in
    CameraView(store: store)
}
.sheet(item: $store.scope(state: \.destination?.rulesModal, action: \.destination.rulesModal)) { store in
    RulesView(store: store)
}
.sheet(item: $store.scope(state: \.destination?.settingsModal, action: \.destination.settingsModal)) { store in
    SettingsView(store: store)
}
```

## 6. Testing Navigation

```swift
@MainActor
func testModalPresentation() async {
    let store = TestStore(initialState: MainFeature.State()) {
        MainFeature()
    }
    
    await store.send(.presentModalTapped) {
        $0.destination = .modal(ModalFeature.State())
    }
    
    await store.send(.destination(.presented(.modal(.delegate(.didDismiss))))) {
        $0.destination = nil
    }
}
```

## Summary

This template covers the three main navigation patterns in TCA:

1. **System Alerts**: Use `@Presents` with `AlertState` for user confirmation/error dialogs
2. **Modal Presentation**: Use `@Presents` with `Destination` enum for sheets and full-screen modals  
3. **Navigation Stack**: Use `StackState` and `NavigationStack` for hierarchical navigation

Key principles:
- State drives navigation declaratively
- Use `@Presents` for modal presentations
- Handle delegate actions for communication between features
- Always connect presentation state with `.ifLet` in the reducer
- Test navigation flows thoroughly with TestStore