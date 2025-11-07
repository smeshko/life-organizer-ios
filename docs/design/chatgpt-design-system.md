# ChatGPT-Inspired Design System (iOS)

version: 1.0
platform: iOS
framework: SwiftUI
last_updated: 2025-11-02
generated_by: GPT-5 Design Agent

---

## Metadata

```json
{
  "schemaVersion": "1.1",
  "checksum": "auto-generate-on-save",
  "agentHelper": {
    "instructions": [
      "Parse all tokens under 'foundations'.",
      "When both 'light' and 'dark' values exist, generate dynamic SwiftUI colors.",
      "Map typography styles to SwiftUI's Font extension.",
      "Use comments for human-readable context; ignore them in parsing."
    ]
  }
}
```

---

## Colors

```json
{
  "light": {
    "background": "#FFFFFF", // App background and scrollable areas
    "surface": "#F5F5F5", // Cards, input fields, modal backgrounds
    "surfaceAlt": "#EDEDED", // Secondary surfaces such as chat bubbles
    "primary": "#10A37F", // Accent color for buttons and focused elements
    "textPrimary": "#000000", // Main text content
    "textSecondary": "#333333", // Supporting text and captions
    "divider": "#E0E0E0", // Separators between content blocks
    "shadow": "rgba(0,0,0,0.1)" // Subtle depth under floating surfaces
  },
  "dark": {
    "background": "#131416", // Global background
    "surface": "#202123", // Primary containers such as chat inputs or cards
    "surfaceAlt": "#2A2B2E", // Secondary surfaces or elevated panels
    "primary": "#10A37F", // Accent color for primary buttons and mic icon
    "textPrimary": "#FFFFFF", // Main readable text
    "textSecondary": "#C5C5C7", // Muted or secondary text
    "divider": "#2E2F33", // Subtle separators
    "shadow": "rgba(0,0,0,0.6)" // Depth shadow for popovers and modals
  }
}
```

---

## Typography

```json
{
  "fontFamily": "SF Pro",
  "styles": {
    "largeTitle": { "size": 34, "weight": "bold", "lineHeight": 41 }, // Section headers or greetings
    "title1": { "size": 28, "weight": "semibold", "lineHeight": 34 }, // Prominent screen titles
    "title2": { "size": 22, "weight": "semibold", "lineHeight": 28 }, // Secondary headings
    "body": { "size": 17, "weight": "regular", "lineHeight": 22 }, // Default text in chat messages
    "callout": { "size": 16, "weight": "medium", "lineHeight": 21 }, // Buttons, small labels
    "caption": { "size": 13, "weight": "regular", "lineHeight": 18 } // Timestamps and metadata
  }
}
```

---

## Spacing

```json
{
  "xxs": 2, // Icon padding
  "xs": 4, // Small internal padding
  "sm": 8, // Base unit for small components
  "md": 16, // Standard margin or padding
  "lg": 24, // Section spacing
  "xl": 32, // Page-level padding
  "xxl": 48 // Hero sections or large margins
}
```

---

## Radii

```json
{
  "none": 0, // Flat edges
  "sm": 6, // Small chips
  "md": 12, // Default for inputs and cards
  "lg": 24, // Rounded capsules (ChatGPT input bar)
  "xl": 32, // Large containers or modals
  "pill": 999 // Fully rounded buttons or avatars
}
```

---

## Shadows

```json
{
  "light": {
    "level1": { "color": "rgba(0,0,0,0.08)", "x": 0, "y": 2, "blur": 4 }, // Cards, chat bubbles
    "level2": { "color": "rgba(0,0,0,0.1)", "x": 0, "y": 4, "blur": 8 } // Modals, sheets
  },
  "dark": {
    "level1": { "color": "rgba(0,0,0,0.4)", "x": 0, "y": 2, "blur": 6 }, // Floating buttons
    "level2": { "color": "rgba(0,0,0,0.6)", "x": 0, "y": 6, "blur": 12 } // Dialogs and overlays
  }
}
```

---

## Animations

```json
{
  "duration": {
    "short": 0.15, // Button taps
    "medium": 0.3, // Modals or transitions
    "long": 0.6 // Complex screen changes
  },
  "curve": {
    "default": "easeInOut", // Standard transitions
    "spring": { "response": 0.55, "dampingFraction": 0.8 } // Natural motion feel
  }
}
```

---

## Icons

```json
{
  "style": "SF Symbols",
  "defaultWeight": "regular",
  "accentWeight": "semibold",
  "sizes": {
    "sm": 16, // Inline actions
    "md": 20, // Toolbar icons
    "lg": 28 // Hero or microphone icons
  },
  "colors": {
    "light": "#555555", // Inactive icon (light mode)
    "dark": "#C8C8CA", // Inactive icon (dark mode)
    "active": "#10A37F" // Active or selected state
  }
}
```
