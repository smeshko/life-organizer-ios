# iOS Application PRD: Life Organization Agent

**Version:** 1.0  
**Date:** November 2, 2025  
**Status:** Ready for Development  
**Project:** Life Organization Agent - iOS Native Application

---

## Executive Summary

A native iOS application for personal use that captures everyday life events through voice or text input and automatically routes them to the appropriate organizational system (shopping lists, reminders, expense tracking, etc.).

**Core Principle:** Simple, reliable capture of life events with minimal friction. The app works both as a Siri background service and as a direct-input interface.

---

## Product Overview

### What This App Does

1. **Accepts input** via voice (Siri or in-app) or text
2. **Sends input to backend** for intelligent classification
3. **Executes iOS actions** based on backend response (create reminders, calendar events)
4. **Provides immediate feedback** to confirm actions completed

### What This App Does NOT Do

- ❌ Complex data visualization or analytics
- ❌ File storage management
- ❌ Multi-user account systems
- ❌ Machine learning or local classification

---

## User Personas

### The User: Busy Individual
- **Need:** Capture thoughts quickly throughout the day
- **Usage:** 10-20 commands per day
- **Context:** Cooking, driving, working, running errands
- **Expectation:** Fast, reliable, requires no thought

---

## User Journeys

### Journey 1: First-Time Setup (5 Minutes)

```
1. Download and open app
   ↓
2. Welcome screen explains what the app does
   [Continue]
   ↓
3. Permission requests with clear explanations:
   - Reminders: "To create tasks and shopping lists"
   - Calendar: "To schedule events"
   - Microphone: "For voice input"
   - Notifications: "To confirm actions"
   ↓
4. Quick tutorial showing both input methods:
   - Voice button
   - Text input
   - Siri commands
   ↓
5. Test input: "Add milk to shopping list"
   ↓
6. Confirmation: "Milk added to shopping list"
   ↓
7. Ready to use
```

---

### Journey 2: Quick Voice Capture (In-App)

```
User opens app while grocery shopping
   ↓
Large voice button visible immediately
   ↓
User taps and holds voice button
   ↓
User speaks: "We're out of milk and bread"
   ↓
User releases button
   ↓
Visual indicator: "Processing..."
   ↓
Backend classifies and responds
   ↓
App creates reminders in "Shopping List"
   ↓
Visual confirmation: "✓ Added milk and bread to shopping list"
Haptic feedback
   ↓
Total time: 3-4 seconds
```

---

### Journey 3: Text Input Alternative

```
User opens app in quiet environment (library, meeting)
   ↓
Text input field visible
   ↓
User types: "Spent 45 euros at restaurant"
   ↓
User taps submit or presses return
   ↓
Visual indicator: "Processing..."
   ↓
Backend classifies as expense
   ↓
Confirmation: "✓ Logged 45 EUR dining expense"
   ↓
Total time: 2-3 seconds
```

---

### Journey 4: Siri Background Mode (Hands-Free)

```
User is cooking, hands dirty
   ↓
User: "Hey Siri, add to shopping list"
   ↓
Siri: "What item?"
   ↓
User: "Olive oil"
   ↓
App Intent processes in background
   ↓
Backend classifies
   ↓
Reminder created
   ↓
Siri: "Added olive oil to shopping list"
   ↓
Total time: 3-4 seconds
User never opened app
```

---

### Journey 5: Reviewing Recent Actions

```
User opens app
   ↓
Home screen shows recent captures:
├─ Added milk (2 minutes ago) ✓
├─ Logged 45 EUR expense (10 minutes ago) ✓
└─ Reminder: Call dentist (1 hour ago) ✓
   ↓
User sees everything is working correctly
   ↓
User closes app
```

---

## Feature Requirements

### Phase 1: Core MVP

**Must Have:**

1. **Text Input Interface**
   - Text field always visible on home screen
   - Submit button
   - Clear indication of processing state
   - Visual confirmation of result

2. **Voice Input Interface**
   - Large, prominent voice button
   - Press-and-hold to record
   - Visual recording indicator
   - Automatic speech-to-text via iOS

3. **Siri App Intents**
   - "Add to shopping list"
   - "Log expense"
   - "Create reminder"
   - Background execution (app doesn't open)

4. **Backend Communication**
   - Send input to classification API
   - Receive structured action response
   - Basic error handling

5. **iOS Reminders Integration**
   - Create reminder in appropriate list
   - Set due dates from backend response
   - Support multiple lists (Shopping, Tasks, etc.)

6. **iOS Calendar Integration**
   - Create calendar events
   - Set times from backend response

7. **Basic UI**
   - Home screen with input methods
   - Recent actions list (last 10)
   - Settings screen
   - Simple, clean design

8. **Permissions Management**
   - Request Reminders access
   - Request Calendar access
   - Request Microphone access
   - Request Notifications access
   - Handle permission denied gracefully

**Explicitly Out of Scope for MVP:**
- Offline queue
- Complex error recovery
- Usage analytics
- Advanced settings
- Multi-device sync

---

### Phase 2: Enhancements (Future)

**Nice to Have:**

1. **Offline Support**
   - Queue actions when backend unavailable
   - Auto-process when reconnected
   - Show queue status

2. **Better Feedback**
   - Custom haptic patterns
   - Richer visual confirmations
   - Sound effects (optional)

3. **User Preferences**
   - Default reminder lists
   - Default times for reminders
   - Preferred input method

4. **History Management**
   - View all past actions
   - Filter by type
   - Undo recent actions

5. **Additional Intents**
   - More Siri phrases
   - Context-aware suggestions

---

## User Interface Design

### Design Principles

1. **Speed First:** Input should be accessible within 1 tap
2. **Visual Clarity:** Always show current state (ready, processing, confirmed)
3. **Minimize Cognitive Load:** No complex navigation or choices
4. **Feedback is Essential:** User must always know what happened

---

### Screen 1: Home Screen (Primary Interface)

**Layout:**

```
┌─────────────────────────────────┐
│  Life Agent              ⚙️      │
│                                 │
│  ┌───────────────────────────┐ │
│  │                           │ │
│  │  What do you want to      │ │
│  │  capture?                 │ │
│  │                           │ │
│  │  [Text input field]       │ │
│  │                           │ │
│  └───────────────────────────┘ │
│                                 │
│         🎤                      │
│    [Voice Button]               │
│    Tap and hold to speak        │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Recent:                        │
│  • Added milk ✓ (2m ago)        │
│  • Logged 45 EUR ✓ (10m)        │
│  • Call dentist ✓ (1h)          │
│                                 │
│  [View All]                     │
│                                 │
└─────────────────────────────────┘
```

**Key Elements:**

- **Text Input:** Always visible, accepts multiline input
- **Voice Button:** Large, centered, clearly labeled
- **Recent Actions:** Shows last 3-5 actions with status
- **Settings Icon:** Top right corner
- **Clean, Uncluttered:** No unnecessary elements

**States:**

- **Ready:** Default state, input methods available
- **Processing:** Spinner shown, input disabled
- **Confirmed:** Green checkmark, brief message, auto-clear
- **Error:** Red indicator, error message, retry option

---

### Screen 2: Processing State

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│           ⏳                     │
│                                 │
│       Processing...             │
│                                 │
│  "Spent 45 euros at restaurant" │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Duration:** 1-3 seconds typically

---

### Screen 3: Confirmation State

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│           ✓                     │
│                                 │
│   Logged 45 EUR dining expense  │
│                                 │
│                                 │
│                                 │
│  [Returns to home after 2s]     │
└─────────────────────────────────┘
```

**Features:**
- Green checkmark
- Clear confirmation message
- Auto-dismiss after 2 seconds
- Haptic feedback

---

### Screen 4: Settings

```
┌─────────────────────────────────┐
│  ← Settings                     │
│                                 │
│  Connection                     │
│  └─ Backend: Connected ✅       │
│                                 │
│  Permissions                    │
│  ├─ Reminders: Granted ✅       │
│  ├─ Calendar: Granted ✅        │
│  ├─ Microphone: Granted ✅      │
│  └─ Notifications: Granted ✅   │
│                                 │
│  Preferences                    │
│  ├─ Preferred input: Voice      │
│  ├─ Haptic feedback: On         │
│  └─ Auto-clear input: On        │
│                                 │
│  Help                           │
│  ├─ Example phrases             │
│  └─ Troubleshooting             │
│                                 │
│  About                          │
│  └─ Version 1.0                 │
│                                 │
└─────────────────────────────────┘
```

---

### Screen 5: Recent Actions (Full List)

```
┌─────────────────────────────────┐
│  ← Recent Actions               │
│                                 │
│  Today                          │
│  ├─ 2:45 PM  Added milk ✓       │
│  │           (Shopping list)    │
│  │                              │
│  ├─ 2:30 PM  Logged 45 EUR ✓    │
│  │           (Dining expense)   │
│  │                              │
│  └─ 1:15 PM  Remind: dentist ✓  │
│              (Tomorrow 10am)    │
│                                 │
│  Yesterday                      │
│  ├─ 6:20 PM  Added bread ✓      │
│  └─ 3:45 PM  Logged 30 EUR ✓    │
│                                 │
│  [Load More]                    │
│                                 │
└─────────────────────────────────┘
```

**Features:**
- Grouped by day
- Shows result of each action
- Tap to see details
- Infinite scroll

---

## Voice Input Specifications

### Recording Flow

1. **User taps and holds voice button**
   - Button changes color (visual feedback)
   - Recording indicator appears
   - Audio recording starts

2. **User speaks**
   - Waveform visualization (optional)
   - Real-time audio level indicator

3. **User releases button**
   - Recording stops
   - Speech-to-text conversion (iOS native)
   - Processing begins

### Voice Button States

- **Ready:** Default blue, "Tap and hold"
- **Recording:** Pulsing red, "Recording..."
- **Processing:** Spinning, "Processing..."
- **Error:** Red with message

### Fallback to Text

If voice recognition fails:
- Show text transcription (if partial)
- Offer "Try again" or "Type instead"
- Allow manual correction

---

## Text Input Specifications

### Input Field Behavior

- **Multiline:** Supports long inputs
- **Auto-capitalize:** First letter of sentence
- **Auto-correct:** iOS standard behavior
- **Submit:** Return key or button
- **Clear:** X button when text present

### Quick Patterns

Common inputs might suggest quick actions:
- Typing "milk" → Suggest "Add to shopping list"
- Typing "50 eur" → Suggest "Log expense"

But this is **optional enhancement**, not MVP.

---

## Siri Integration

### Supported Phrases

**Shopping:**
- "Hey Siri, add to shopping list"
- "Hey Siri, we're out of..."
- "Hey Siri, need to buy..."

**Expenses:**
- "Hey Siri, log expense"
- "Hey Siri, I spent..."

**Reminders:**
- "Hey Siri, remind me to..."
- "Hey Siri, don't forget to..."

**General:**
- "Hey Siri, quick capture"

### Siri Response Flow

1. Siri recognizes phrase
2. App Intent launches (background)
3. Siri may ask for details if needed
4. App processes with backend
5. Siri confirms result
6. App never opened

---

## Backend Communication

### Request Format

Simple JSON POST to classification endpoint:

```
POST /classify
{
  "input": "User's spoken or typed text",
  "timestamp": "ISO 8601 timestamp",
  "context": {
    "platform": "iOS",
    "version": "1.0"
  }
}
```

### Response Format

Backend returns structured action:

```
{
  "success": true,
  "action": "create_reminder" | "create_event" | "log_expense",
  "data": {
    // Action-specific data
  },
  "message": "Human-readable confirmation"
}
```

### Error Handling

**Backend unreachable:**
- Show error message: "Can't reach server"
- Offer "Try again" button
- No offline queue (MVP)

**Backend returns error:**
- Show error message
- Allow retry or manual input

**Backend timeout (>5 seconds):**
- Show timeout message
- Cancel request

---

## Permissions Strategy

### Required Permissions

1. **Reminders (Critical)**
   - Requested: On first use that needs it
   - Explanation: "To create tasks and shopping lists"
   - If denied: Show alert, link to Settings

2. **Calendar (Important)**
   - Requested: On first calendar event
   - Explanation: "To schedule events"
   - If denied: Can still do reminders

3. **Microphone (Important)**
   - Requested: On first voice button tap
   - Explanation: "To capture your voice"
   - If denied: Text input still works

4. **Notifications (Nice to Have)**
   - Requested: During onboarding
   - Explanation: "To confirm actions"
   - If denied: Use visual feedback only

### Permission Re-request Flow

If user denies permission:
1. Show explanation of why it's needed
2. Show "Open Settings" button
3. Deep link to app settings
4. Check permission status on app resume

---

## Error Handling Philosophy

### User-Facing Errors

All errors should:
1. **Explain what happened** in plain language
2. **Suggest an action** the user can take
3. **Not use technical jargon** or error codes

**Examples:**

✅ Good: "Can't create reminder. Please enable Reminders access in Settings."
❌ Bad: "Error: EKEventStore authorization status denied"

✅ Good: "Server not responding. Check your internet connection."
❌ Bad: "NSURLErrorDomain -1009"

### Error Recovery

- **Transient errors:** Offer "Try Again" button
- **Permission errors:** Link to Settings
- **Backend errors:** Show what was captured, offer to retry
- **Unknown errors:** Show generic message, log for debugging

---

## Performance Requirements

### Target Metrics

- **App launch:** <1 second to ready state
- **Text input response:** <2 seconds total
- **Voice input response:** <4 seconds total
- **Siri command:** <5 seconds total

### Resource Constraints

- **App size:** <20MB
- **Memory usage:** <100MB
- **Battery impact:** Minimal (<1% per day)
- **Network:** <1KB per request

---

## Accessibility

### Must Support

1. **VoiceOver:** All UI elements properly labeled
2. **Dynamic Type:** Text scales with system settings
3. **Voice Control:** Alternative to touch input
4. **Keyboard Navigation:** For hardware keyboards

### Design Considerations

- Large touch targets (minimum 44x44 points)
- High contrast text
- Clear visual feedback
- Support for reduced motion

---

## Privacy & Security

### Data Handling

**What leaves the device:**
- Text/voice input content
- Timestamp
- Device type (iOS)

**What stays local:**
- Reminders and calendar events
- Permission status
- Settings preferences

**What is NOT collected:**
- Location data
- Contact information
- Other app usage
- Personal identifiers (beyond input content)

### Security

- All network requests over HTTPS
- No persistent storage of input text
- No crash reporting (MVP)
- No analytics (MVP)

---

## Future Enhancement Ideas

### Phase 2 (Next Month)

- Offline queue for failed requests
- Undo recent actions
- Apple Watch companion app
- Widgets for home screen
- Shortcuts app actions

### Phase 3 (Later)

- Voice recognition for family members
- Learning from corrections
- Batch operations
- Location-based triggers
- Photo capture with voice notes

---

## Technical Constraints

### Platform Requirements

- **iOS Version:** 16.0+ (for App Intents)
- **Devices:** iPhone (iPad compatible but not optimized)
- **Languages:** English only (MVP)

### Dependencies

- No third-party frameworks for MVP
- Use native iOS frameworks only:
  - EventKit (Reminders, Calendar)
  - Speech (Voice recognition)
  - AVFoundation (Audio recording)
  - Foundation (Networking)

---

## Open Questions

1. Should the app support landscape mode?
   - **Decision:** Portrait only for MVP (simpler)

2. Should voice button work with tap-to-start, tap-to-stop?
   - **Decision:** Hold-to-record only (more reliable)

3. Should the app show backend classification confidence?
   - **Decision:** No, just show result (keep simple)

4. Should the app allow editing of created reminders?
   - **Decision:** No, use Reminders app for that (avoid scope creep)

5. Should there be a dark mode?
   - **Decision:** Yes, follow system setting (easy to implement)

---

## Definition of Done

### MVP is Complete When:

1. ✅ User can input via text field
2. ✅ User can input via voice button
3. ✅ User can trigger via Siri commands
4. ✅ Backend communication works reliably
5. ✅ Reminders are created correctly
6. ✅ Calendar events are created correctly
7. ✅ All permissions are properly requested
8. ✅ Error messages are clear and helpful
9. ✅ Recent actions are displayed
10. ✅ App works in daily use without issues

### Quality Bar

- No crashes during normal use
- Responses feel fast (<5 seconds)
- Permissions flow is smooth
- Error messages make sense
- Visual feedback is clear

---

## Conclusion

This app is intentionally simple and focused. It's an input interface for capturing life events, with the intelligence living in the backend. The app should feel invisible - quick to open, quick to use, quick to close.

**Core Experience:** Open app → Speak or type → Get confirmation → Done.

**Timeline:** 2-3 weeks of focused development for MVP

**Philosophy:** Build the simplest thing that works, iterate based on real usage.