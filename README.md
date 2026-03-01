# native_kit

Native iOS components for Flutter apps to support iOS 26 "Liquid Design".

This package provides platform-native UI components implemented in Swift and bridged to Flutter, so your app can adopt the latest iOS 26 Liquid aesthetics while keeping a single Flutter codebase.

## Status
Early work-in-progress. APIs and components may change.

## Platforms
- iOS: iOS 18.0+ required; designed for iOS 26 Liquid Design guidelines.
- macOS: basic support where applicable.
- Other platforms: automatic fallback to Flutter Cupertino widgets.

## Installation
Add to your `pubspec.yaml`:

```yaml
dependencies:
  native_kit:
    git:
      url: https://github.com/nicourrrn/native_kit.git
```

Then run:
```bash
flutter pub get
```

## Components

| Component | Description | iOS Native | Fallback |
|-----------|-------------|-----------|----------|
| **NKTabBar** | Bottom tab bar | `UITabBar` | `BottomNavigationBar` |
| **NKSwitch** | Toggle switch | `UISwitch` | `CupertinoSwitch` |
| **NKSlider** | Value slider | `UISlider` | `CupertinoSlider` |
| **NKButton** | Button (6 styles) | `UIButton.Configuration` | `CupertinoButton` |
| **NKSegmentedControl** | Segmented picker | `UISegmentedControl` | `CupertinoSlidingSegmentedControl` |
| **NKIcon** | SF Symbol renderer | `UIImageView` | `Icon` |
| **NKPopupMenu** | Context menu | `UIMenu` + `UIButton` | `CupertinoActionSheet` |

All components use the `NK` prefix (NativeKit) and share a consistent architecture:
- Per-view method channels for multi-instance support
- SF Symbols integration via `NKSFSymbol`
- Automatic fallback to Cupertino widgets on non-iOS platforms

---

### NKTabBar

A native iOS bottom tab bar with badge support and custom action buttons.

```dart
NKTabBar(
  items: [
    NKTabBarItem(
      title: 'Home',
      icon: NKSFSymbols.house,
      selectedIcon: NKSFSymbols.houseFill,
    ),
    NKTabBarItem(
      title: 'Search',
      icon: NKSFSymbols.magnifyingglass,
      badge: '3',
    ),
    NKTabBarItem(
      title: 'Profile',
      icon: NKSFSymbols.person,
      selectedIcon: NKSFSymbols.personFill,
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  onTap: (index) => setState(() => _selectedIndex = index),
)
```

**Features:** badges, selected/unselected icon states, custom action buttons via `NKTabBarItem.customButton()`, color customization.

---

### NKSwitch

A native iOS toggle switch.

```dart
NKSwitch(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
  activeColor: Colors.green,
)
```

**Props:** `value`, `onChanged`, `activeColor`, `trackColor`, `thumbColor`, `enabled`.

---

### NKSlider

A native iOS slider with optional step snapping.

```dart
NKSlider(
  value: _volume,
  min: 0.0,
  max: 100.0,
  step: 25,
  onChanged: (value) => setState(() => _volume = value),
  activeColor: Colors.blue,
)
```

**Props:** `value`, `onChanged`, `onChangeStart`, `onChangeEnd`, `min`, `max`, `step`, `activeColor`, `inactiveColor`, `thumbColor`, `enabled`.

---

### NKButton

A native iOS button with 6 visual styles mapped to `UIButton.Configuration`.

```dart
NKButton(
  label: 'Sign In',
  icon: NKSFSymbols.person,
  style: NKButtonStyle.filled,
  tintColor: Colors.blue,
  onPressed: () => print('Pressed!'),
)

// Icon-only variant
NKButton.icon(
  icon: NKSFSymbols.heartFill,
  style: NKButtonStyle.plain,
  tintColor: Colors.red,
  onPressed: () {},
)
```

**Styles:** `plain`, `gray`, `tinted`, `bordered`, `borderedProminent`, `filled`.

**Props:** `label`, `icon`, `style`, `onPressed`, `tintColor`, `enabled`.

---

### NKSegmentedControl

A native iOS segmented control with optional SF Symbol icons.

```dart
NKSegmentedControl(
  labels: ['Day', 'Week', 'Month'],
  selectedIndex: _selectedIndex,
  onValueChanged: (index) => setState(() => _selectedIndex = index),
  tintColor: Colors.blue,
)
```

**Props:** `labels`, `icons` (optional `List<NKSFSymbol?>`), `selectedIndex`, `onValueChanged`, `tintColor`, `enabled`.

---

### NKIcon

A native SF Symbol renderer with 4 rendering modes.

```dart
NKIcon(
  symbol: NKSFSymbols.heart,
  size: 32.0,
  color: Colors.red,
)

// Multi-color rendering
NKIcon(
  symbol: NKSFSymbol('cloud.sun.rain.fill'),
  size: 48.0,
  mode: NKSymbolRenderingMode.multicolor,
)

// Palette rendering
NKIcon(
  symbol: NKSFSymbol('person.crop.circle.badge.checkmark'),
  size: 48.0,
  mode: NKSymbolRenderingMode.palette,
  color: Colors.blue,
  secondaryColor: Colors.green,
)
```

**Modes:** `monochrome`, `hierarchical`, `palette`, `multicolor`.

**Props:** `symbol`, `size`, `color`, `mode`, `secondaryColor`, `tertiaryColor`.

---

### NKPopupMenu

A native iOS context menu with dividers, checkmarks, and destructive styling.

```dart
NKPopupMenu(
  buttonLabel: 'Options',
  buttonIcon: NKSFSymbol('ellipsis.circle'),
  items: [
    NKPopupMenuItem(label: 'Edit', icon: NKSFSymbol('pencil')),
    NKPopupMenuItem(label: 'Share', icon: NKSFSymbol('square.and.arrow.up')),
    NKPopupMenuDivider(),
    NKPopupMenuItem(
      label: 'Delete',
      icon: NKSFSymbol('trash'),
      isDestructive: true,
    ),
  ],
  onSelected: (index) => print('Selected: $index'),
)
```

**Props:** `buttonLabel`, `buttonIcon`, `items`, `onSelected`, `tintColor`.

**Item types:** `NKPopupMenuItem` (with `isChecked`, `isDestructive`), `NKPopupMenuDivider`.

---

## SF Symbols

All components share the `NKSFSymbol` system:

```dart
// Predefined constants
NKSFSymbols.house
NKSFSymbols.heartFill

// Custom symbols
NKSFSymbol('your.custom.symbol')

// With configuration
NKSFSymbol('gear', config: NKSFSymbolConfig(weight: 'bold', scale: 'large'))
```

Browse all symbols: [SF Symbols App](https://developer.apple.com/sf-symbols/)

## Example App

```bash
cd example
flutter run
```

The example app demonstrates all 7 components with interactive demos.

## Architecture

```
lib/
  src/
    models/          - Shared NKSFSymbol model
    utilities/       - Platform view mixin, platform builder
    components/
      nk_tab_bar/    - NKTabBar widget + item model
      nk_switch/     - NKSwitch widget
      nk_slider/     - NKSlider widget
      nk_button/     - NKButton widget + style enum
      nk_segmented_control/ - NKSegmentedControl widget
      nk_icon/       - NKIcon widget + rendering mode enum
      nk_popup_menu/ - NKPopupMenu widget + item model

ios/Classes/
  Utilities/         - Color + SF Symbol Swift helpers
  Components/        - One factory + platform view per component
```

Each component uses per-view method channels (`native_kit/{component}_{viewId}`) for reliable multi-instance support.

## License and Attribution

This project is free to use and copy, with a mandatory requirement to credit the author. See the LICENSE file for details.
