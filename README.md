# native_kit

Native iOS components for Flutter apps to support iOS 26 "Liquid Design".

This package provides platform-native UI pieces implemented in Swift and bridged to Flutter, so your app can adopt the latest iOS 26 Liquid aesthetics while keeping a single Flutter codebase.

## Status
Early work-in-progress. APIs and components may change.

## Platforms
- iOS: iOS 18.0+ required; designed for iOS 26 Liquid Design guidelines.
- macOS: basic support where applicable.

## Installation
Add to your `pubspec.yaml`:

```yaml
dependencies:
  native_kit:
    git:
      url: https://github.com/yourusername/native_kit.git
```

Then run:
```bash
flutter pub get
```

## Components

### NKTabBar - Native Bottom Tab Bar

A native iOS bottom tab bar widget using `UITabBar` for authentic iOS look and feel. The `NK` prefix indicates this is a NativeKit component.

**Use it like Flutter's `BottomNavigationBar`, but with native iOS rendering!**

#### Features
- 🎯 Flutter widget - use in `Scaffold.bottomNavigationBar`
- 🎨 Full customization (colors, icons, badges)
- 🔔 Badge support with real-time updates
- 🎯 Type-safe icon system
- 📦 SF Symbols support
- ⚡ Native performance with Platform View
- 🎭 Selected/unselected icon states
- 🔄 Reactive updates on state changes
- ➕ Custom action button that unfocuses after tap

#### Basic Usage

```dart
import 'package:native_kit/native_kit.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NKTabBar(
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
```

#### Icon Types

NKTabBar supports SF Symbols through a type-safe API:

```dart
// Using predefined symbols
NKTabBarItem(
  title: 'Home',
  icon: NKSFSymbols.house,
  selectedIcon: NKSFSymbols.houseFill,
)

// Custom SF Symbol with configuration
NKTabBarItem(
  title: 'Settings',
  icon: NKSFSymbol(
    'gear',
    config: NKSFSymbolConfig(
      weight: 'bold',
      scale: 'large',
    ),
  ),
)
```

#### Customization

```dart
NKTabBar(
  items: [
    NKTabBarItem(
      title: 'Home',
      icon: NKSFSymbols.house,
    ),
    NKTabBarItem(
      title: 'Search',
      icon: NKSFSymbols.magnifyingglass,
    ),
  ],
  currentIndex: _selectedIndex,
  backgroundColor: Colors.white,
  selectedItemColor: const Color(0xFF007AFF),  // iOS blue
  unselectedItemColor: const Color(0xFF8E8E93), // iOS gray
  height: 60.0,  // Custom height
  onTap: (index) => setState(() => _selectedIndex = index),
)
```

#### Custom Action Button

Add a custom action button that appears in the same row as the tab bar, aligned to the right. This button triggers actions without switching tabs:

```dart
NKTabBar(
  items: [
    NKTabBarItem(
      title: 'Home',
      icon: NKSFSymbols.house,
    ),
    // Custom action button - appears on the right side of tab bar!
    NKTabBarItem.customButton(
      icon: NKSFSymbols.plusCircleFill,
    ),
    NKTabBarItem(
      title: 'Profile',
      icon: NKSFSymbols.person,
    ),
    NKTabBarItem(
      title: 'Settings',
      icon: NKSFSymbols.gear,
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) {
    // Handle regular tab selection
    setState(() => _selectedIndex = index);
  },
  onCustomButtonTap: (index) {
    // Handle custom button tap (e.g., show create dialog)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create'),
        content: const Text('Create new content!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  },
)
```

**Key Points:**
- Custom action buttons are created with `NKTabBarItem.customButton()`
- They render as a **button in the same row as the tab bar**, aligned to the right
- Same height as the tab bar (49pt)
- Use default iOS button styling with system tint color
- They automatically unfocus after tap, restoring the previous tab selection
- They trigger `onCustomButtonTap` instead of `onTap`
- Perfect for actions like creating posts, opening camera, compose, etc.
- Supports any SF Symbol icon

#### Available SF Symbols

`NKSFSymbols` provides convenient constants for common icons:

**Navigation:**
- `house`, `houseFill`
- `magnifyingglass`
- `person`, `personFill`
- `gear`, `gearFill`

**Actions:**
- `heart`, `heartFill`
- `star`, `starFill`
- `bookmark`, `bookmarkFill`

**Communication:**
- `bell`, `bellFill`
- `envelope`, `envelopeFill`
- `message`, `messageFill`

**Media:**
- `play`, `playFill`
- `pause`, `pauseFill`
- `photo`, `photoFill`

**Shopping:**
- `cart`, `cartFill`
- `bag`, `bagFill`

**Location:**
- `location`, `locationFill`
- `map`, `mapFill`

Browse all symbols: [SF Symbols App](https://developer.apple.com/sf-symbols/)

Or use custom SF Symbols: `NKSFSymbol('your.custom.symbol')`

#### Dynamic Updates

NKTabBar is reactive - it automatically updates when you change the widget properties:

```dart
// Update badge - just change the state and rebuild
setState(() {
  _badgeCount++;
});

// The badge will update automatically in the widget
NKTabBar(
  items: [
    NKTabBarItem(
      title: 'Home',
      icon: NKSFSymbols.house,
      badge: _badgeCount > 0 ? _badgeCount.toString() : null,
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
)
```

#### API Reference

**NKTabBar Widget Properties:**
- `items` (List<NKTabBarItem>) - Required. List of tab bar items
- `currentIndex` (int) - Current selected tab index (default: 0)
- `onTap` (ValueChanged<int>?) - Callback when a regular tab is tapped
- `onCustomButtonTap` (ValueChanged<int>?) - Callback when a custom button is tapped
- `backgroundColor` (Color?) - Background color of the tab bar
- `selectedItemColor` (Color?) - Color of the selected item
- `unselectedItemColor` (Color?) - Color of unselected items
- `height` (double?) - Height of the tab bar

**NKTabBarItem Properties:**
- `title` (String) - Item title text
- `icon` (NKTabBarIcon?) - Icon to display
- `selectedIcon` (NKTabBarIcon?) - Icon when selected (optional)
- `badge` (String?) - Badge text (optional)
- `customColor` (Color?) - Custom color override (optional)
- `isCustomButton` (bool) - Whether this is a custom action button (default: false)

**NKTabBarItem Constructors:**
- `NKTabBarItem({...})` - Standard tab item with SF Symbol icon
- `NKTabBarItem.customButton({icon, title})` - Custom action button (renders on the right side of tab bar)

**NKTabBarIcon Types:**
- `NKSFSymbol(name, {config})` - SF Symbol icon

**NKSFSymbols Constants:**
- Pre-defined SF Symbol constants for common icons
- Example: `NKSFSymbols.house`, `NKSFSymbols.magnifyingglass`, etc.

## Example App

Run the example to see `NKTabBar` in action:

```bash
cd example
flutter run
```

The example demonstrates:
- Using `NKTabBar` as a Flutter widget in `bottomNavigationBar`
- Type-safe icon system with `NKSFSymbols`
- Custom action button positioned on the right side
- Dynamic badge updates
- Tab selection handling with state management
- SF Symbols with filled/outlined states
- Different page content for each tab

## Project Structure

```
native_kit/
├── lib/
│   ├── src/
│   │   └── components/
│   │       └── nk_tab_bar/
│   │           ├── nk_tab_bar.dart
│   │           ├── nk_tab_bar_item.dart
│   │           └── nk_tab_bar_icon.dart
│   └── native_kit.dart
├── ios/
│   └── Classes/
│       ├── NavBar/
│       │   └── NavBarHandler.swift
│       └── NativeKitPlugin.swift
└── example/
    └── lib/
        └── main.dart
```

The architecture uses a clean component-based structure where all NativeKit components are prefixed with `NK` for easy identification.

## Roadmap

Future components planned:
- Native alerts and action sheets
- Native date/time pickers
- Native context menus
- Native search bars
- More coming soon...

## Contributing

Contributions welcome! Please open an issue or PR.

## License and Attribution

This project is free to use and copy, with a mandatory requirement to credit the author. See the LICENSE file for details on how to attribute the work.

