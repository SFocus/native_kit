# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**native_kit** is a Flutter plugin that provides native iOS components (Swift/UIKit) bridged to Flutter via platform views and method channels. It targets iOS 18.0+ and aims to support iOS 26 "Liquid Design". Early stage (v0.0.2).

## Common Commands

```bash
flutter pub get                    # Install dependencies
flutter analyze                    # Run Dart static analysis
flutter test                       # Run unit tests
flutter test test/native_kit_test.dart  # Run a single test file
cd example && flutter run          # Run the example app on iOS simulator
```

Linting uses `flutter_lints` v6.0.0 (see `analysis_options.yaml`).

## Architecture

### Plugin Structure (Dart ↔ Swift bridge)

The plugin uses Flutter's **platform view** pattern with **method channels** for bidirectional communication:

- **Dart side** (`lib/`): Widgets wrap `UiKitView` to embed native iOS views. State changes trigger method channel calls to update the native view.
- **Swift side** (`ios/Classes/`): `FlutterPlatformViewFactory` creates native UIKit views. A `FlutterMethodChannel` receives update calls from Dart.

### Method Channels

| Channel Name | Purpose |
|---|---|
| `native_kit` | Main plugin channel (e.g., `getPlatformVersion`) |
| `native_kit/tab_bar` | Tab bar component updates |
| `native_kit/tab_bar_view` | Platform view registration ID |

### Component Pattern

Each component lives in `lib/src/components/nk_<name>/` (Dart) and `ios/Classes/Components/NK<Name>/` (Swift). All public types use the `NK` prefix.

A component typically consists of:
- **Widget** (`nk_<name>.dart`) — StatefulWidget using `UiKitView`, sends serialized config via method channel on state changes
- **Data model** (`nk_<name>_item.dart`) — Item/config classes with `toMap()` serialization for the platform channel
- **Type definitions** (`nk_<name>_icon.dart`) — Sealed class hierarchies for type-safe enums (e.g., icon types)
- **Swift factory** (`NK<Name>ViewFactory.swift`) — `FlutterPlatformViewFactory` + `FlutterPlatformView` implementation that creates and updates UIKit views

### Registration Flow

`NativeKitPlugin.register()` in Swift sets up method channels and registers platform view factories. iOS 18.0+ availability is checked at registration time via `#available`.

### Exports

All public API is re-exported through `lib/native_kit.dart`. New components must be added there.

## Conventions

- **NK prefix**: All public Dart types and Swift classes use the `NK` prefix
- **SF Symbols**: Icons use Apple SF Symbols; type-safe constants in `NKSFSymbols`, custom symbols via `NKSFSymbol('name')`
- **Sealed classes**: Used for type-safe discriminated unions (e.g., `NKTabBarIcon`)
- **Serialization**: Dart models provide `toMap()` methods; Swift side parses dictionaries from method channel arguments
- **Platform guard**: Native features are gated with `#available(iOS 18.0, *)` in Swift
