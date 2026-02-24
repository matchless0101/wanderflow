# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WanderFlow is a SwiftUI + SwiftData application for iOS/macOS. It's a starter template app that demonstrates basic CRUD operations with SwiftData persistence.

## Build & Run Commands

```bash
# Open in Xcode
open WanderFlow.xcodeproj

# Build via command line (macOS)
xcodebuild -project WanderFlow.xcodeproj -scheme WanderFlow -configuration Debug build

# Build for iOS Simulator
xcodebuild -project WanderFlow.xcodeproj -scheme WanderFlow -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build

# Archive for App Store (requires Xcode Cloud or local signing)
xcodebuild -project WanderFlow.xcodeproj -scheme WanderFlow -configuration Release archive
```

## Architecture

- **SwiftUI** for the UI framework
- **SwiftData** (`@Model`, `ModelContainer`, `@Query`) for data persistence
- **NavigationSplitView** for the three-column layout pattern

### File Structure

```
WanderFlow/
├── WanderFlowApp.swift       # App entry point, ModelContainer setup
├── ContentView.swift         # Main UI with List, NavigationSplitView
├── Item.swift                # SwiftData @Model for persistence
└── Assets.xcassets/          # App icons and colors

WanderFlow.xcodeproj/         # Xcode project configuration
```

## Development

- The app Notes uses SwiftData's `ModelContainer` configured in `WanderFlowApp.swift:13-24`
- `Item` is a `@Model` class stored with automatic persistence
- `ContentView` uses `@Query` to observe `Item` changes reactively
- Preview provider uses in-memory storage: `.modelContainer(for: Item.self, inMemory: true)`
