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
| **NKButton** | Button (10 styles) | `UIButton.Configuration` | `CupertinoButton` |
| **NKSegmentedControl** | Segmented picker | `UISegmentedControl` | `CupertinoSlidingSegmentedControl` |
| **NKIcon** | SF Symbol renderer | `UIImageView` | `Icon` |
| **NKPopupMenu** | Context menu | `UIMenu` + `UIButton` | `CupertinoActionSheet` |
| **NKToolbar** | Navigation bar | `UINavigationBar` | — |
| **SliverNKToolbar** | Collapsible nav bar | `UINavigationBar` | — |
| **NKProgressView** | Progress indicator | `UIProgressView` / `UIActivityIndicatorView` | `CupertinoActivityIndicator` |
| **NKDatePicker** | Date & time picker | `UIDatePicker` | — |
| **NKGlassContainer** | Glass background | Liquid Glass material | `Container` |
| **NKGlassCard** | Glass card | Liquid Glass material | `Container` |
| **NKGlassButtonGroup** | Grouped glass buttons | Liquid Glass buttons | `CupertinoButton` |
| **NKToast** | Toast notification | Liquid Glass overlay | `OverlayEntry` |

All components use the `NK` prefix (NativeKit) and share a consistent architecture:
- Per-view method channels for multi-instance support
- SF Symbols integration via `NKSFSymbol`
- Automatic fallback to Cupertino widgets on non-iOS platforms
- Global theming via `NKTheme` with per-component overrides

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

A native iOS slider with optional step snapping and iOS 26 tick marks.

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

**Props:** `value`, `onChanged`, `onChangeStart`, `onChangeEnd`, `min`, `max`, `step`, `activeColor`, `inactiveColor`, `thumbColor`, `enabled`, `numberOfTicks`, `allowsTickValuesOnly`, `neutralValue`.

---

### NKButton

A native iOS button with 10 visual styles mapped to `UIButton.Configuration`.

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

**Styles:** `plain`, `gray`, `tinted`, `bordered`, `borderedProminent`, `filled`, `glass`, `clearGlass`, `prominentGlass`, `prominentClearGlass`.

**Props:** `label`, `icon`, `style`, `onPressed`, `tintColor`, `enabled`, `textStyle`, `cornerRadius`.

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

**Props:** `labels`, `icons` (optional `List<NKSFSymbol?>`), `selectedIndex`, `onValueChanged`, `tintColor`, `enabled`, `textStyle`, `cornerRadius`.

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

### NKToolbar

A native iOS navigation bar (`UINavigationBar`) for use as `Scaffold.appBar`.

```dart
Scaffold(
  appBar: NKToolbar(
    title: 'Settings',
    onBackPressed: () => Navigator.of(context).pop(),
    tintColor: Colors.blue,
    trailingItems: [
      NKToolbarItem(
        label: 'Done',
        onPressed: () {},
      ),
    ],
  ),
  body: ...,
)
```

**Props:** `title`, `prefersLargeTitles`, `onBackPressed`, `backButtonTitle`, `leadingItem`, `trailingItems`, `tintColor`, `backgroundColor`, `appearance`, `showSeparator`, `searchBar`, `titleTextStyle`.

**Appearances:** `defaultAppearance`, `transparent`, `opaque`.

---

### SliverNKToolbar

A sliver-based native navigation bar with collapsible large titles. Use inside a `CustomScrollView`.

```dart
CustomScrollView(
  slivers: [
    SliverNKToolbar(
      title: 'Settings',
      onBackPressed: () => Navigator.of(context).pop(),
      tintColor: Colors.blue,
      trailingItems: [
        NKToolbarItem(label: 'Done', onPressed: () {}),
      ],
    ),
    SliverList(...),
  ],
)
```

The large title is rendered in Flutter and collapses as you scroll, transitioning to a native inline title in the navigation bar.

**Props:** `title`, `onBackPressed`, `backButtonTitle`, `leadingItem`, `trailingItems`, `tintColor`, `backgroundColor`, `appearance`, `searchBar`, `titleTextStyle`.

---

### NKProgressView

A native iOS progress indicator — either a bar (`UIProgressView`) or spinner (`UIActivityIndicatorView`). Gets Liquid Glass styling automatically on iOS 26+.

```dart
// Determinate bar
NKProgressView(
  style: NKProgressViewStyle.bar,
  value: 0.65,
  tintColor: Colors.blue,
)

// Spinner
NKProgressView(
  style: NKProgressViewStyle.spinner,
  spinnerSize: NKSpinnerSize.large,
)
```

**Props:** `style` (`bar`/`spinner`), `value` (0.0–1.0, bar only), `tintColor`, `trackColor`, `spinnerSize` (`small`/`medium`/`large`), `cornerRadius`.

---

### NKDatePicker

A native iOS date picker supporting all modes and styles.

```dart
// Compact date and time picker
NKDatePicker(
  mode: NKDatePickerMode.dateAndTime,
  style: NKDatePickerStyle.compact,
  initialDate: DateTime.now(),
  onDateChanged: (date) => setState(() => _selectedDate = date),
)

// Inline calendar
NKDatePicker(
  mode: NKDatePickerMode.date,
  style: NKDatePickerStyle.inline,
  tintColor: Colors.blue,
  onDateChanged: (date) => setState(() => _selectedDate = date),
)
```

**Modes:** `date`, `time`, `dateAndTime`, `countdownTimer`.

**Styles:** `compact`, `inline`, `wheels`.

**Props:** `mode`, `style`, `initialDate`, `minimumDate`, `maximumDate`, `countdownDuration`, `minuteInterval`, `onDateChanged`, `onCountdownChanged`, `tintColor`.

---

### NKGlassContainer

A Liquid Glass background container (iOS 26+). Falls back to a plain `Container` on earlier versions.

```dart
NKGlassContainer(
  style: NKGlassStyle.regular,
  cornerRadius: 20,
  padding: EdgeInsets.all(16),
  child: Text('Glass content'),
)

// Capsule shape
NKGlassContainer(
  capsule: true,
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  child: Text('Capsule'),
)
```

**Props:** `style` (`regular`/`clear`), `cornerRadius`, `capsule`, `tintColor`, `isInteractive`, `padding`, `width`, `height`, `child`.

---

### NKGlassCard

A glass-styled card with an optional title. Composes `NKGlassContainer`.

```dart
NKGlassCard(
  title: 'Settings',
  tintColor: Colors.blue,
  child: Text('Card content'),
)
```

**Props:** `title`, `titleStyle`, `style`, `tintColor`, `cornerRadius`, `padding`, `width`, `child`.

---

### NKGlassButtonGroup

A group of Liquid Glass buttons displayed in a horizontal row.

```dart
NKGlassButtonGroup(
  buttons: [
    NKGlassButton(label: 'Like', icon: NKSFSymbols.heart, onPressed: () {}),
    NKGlassButton(label: 'Share', icon: NKSFSymbol('square.and.arrow.up'), onPressed: () {}),
    NKGlassButton(label: 'Save', icon: NKSFSymbol('bookmark'), onPressed: () {}),
  ],
)
```

**Props:** `buttons`, `spacing`, `height`.

---

### NKToast

An imperative toast notification with Liquid Glass styling.

```dart
// Show a toast
NKToast.show(
  context,
  message: 'Item saved!',
  icon: NKSFSymbol('checkmark.circle.fill'),
  position: NKToastPosition.top,
);

// Dismiss early
final dismiss = NKToast.show(context, message: 'Loading...');
// ...later:
dismiss();
```

**Props:** `message`, `icon`, `style`, `tintColor`, `duration`, `position` (`top`/`bottom`), `onDismissed`.

---

## Custom Fonts

native_kit components render with the iOS system font (SF Pro) by default. You can use custom fonts from your Flutter project in native UIKit views through `NKFontLoader` and `NKTextStyle`.

### 1. Add fonts to your project

Declare fonts in your `pubspec.yaml` as usual:

```yaml
flutter:
  assets:
    - assets/fonts/

  fonts:
    - family: MyFont
      fonts:
        - asset: assets/fonts/MyFont-Regular.ttf
        - asset: assets/fonts/MyFont-Bold.ttf
          weight: 700
```

### 2. Register fonts with native iOS

Flutter fonts are bundled as assets but **not** automatically available to native UIKit views. Call `NKFontLoader.registerFont()` at app startup to make them available:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register each font file individually
  await NKFontLoader.registerFonts([
    'assets/fonts/MyFont-Regular.ttf',
    'assets/fonts/MyFont-Bold.ttf',
  ]);

  runApp(const MyApp());
}
```

Fonts from **package dependencies** are also supported:

```dart
await NKFontLoader.registerFontFromPackage(
  'fonts/PackageFont.ttf',
  package: 'my_font_package',
);
```

Any valid Flutter asset path works — `assets/`, `src/fonts/`, or any other declared asset directory.

### 3. Apply fonts with NKTextStyle

Use `NKTextStyle` to set font family, size, and weight on individual components:

```dart
NKButton(
  label: 'Custom Font',
  style: NKButtonStyle.filled,
  textStyle: NKTextStyle(
    fontFamily: 'MyFont',
    fontSize: 16,
    fontWeight: NKFontWeight.bold,
  ),
  onPressed: () {},
)
```

`NKTextStyle` is supported on: **NKButton**, **NKTabBar**, **NKToolbar** / **SliverNKToolbar**, **NKSegmentedControl**.

`cornerRadius` is supported on: **NKButton**, **NKSegmentedControl**, **NKProgressView**.

### 4. Global theming with NKTheme

Wrap your widget tree with `NKTheme` to set defaults for all NK components. Per-component properties always override theme defaults.

```dart
NKTheme(
  data: NKThemeData(
    textStyle: NKTextStyle(
      fontFamily: 'MyFont',
      fontSize: 14,
      fontWeight: NKFontWeight.semibold,
    ),
    cornerRadius: 12.0,
    tintColor: Colors.indigo,
  ),
  child: MaterialApp(...),
)
```

Components resolve styling in this order: **widget property > NKTheme > system default**.

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

The example app demonstrates all components with interactive demos, including a custom fonts page showing `NKFontLoader`, `NKTheme`, and per-component styling overrides.

## Architecture

```
lib/
  native_kit.dart      - Barrel exports
  src/
    models/            - NKSFSymbol, NKTextStyle, NKGlassStyle, NKTheme
    utilities/         - NKFontLoader, platform view mixin, platform builder
    components/
      nk_tab_bar/      - NKTabBar + NKTabBarItem
      nk_switch/       - NKSwitch
      nk_slider/       - NKSlider
      nk_button/       - NKButton + style enum
      nk_segmented_control/ - NKSegmentedControl
      nk_icon/         - NKIcon + rendering mode enum
      nk_popup_menu/   - NKPopupMenu + NKPopupMenuItem
      nk_toolbar/      - NKToolbar + SliverNKToolbar
      nk_progress_view/ - NKProgressView
      nk_date_picker/  - NKDatePicker
      nk_glass_container/ - NKGlassContainer
      nk_glass_card/   - NKGlassCard
      nk_glass_button_group/ - NKGlassButtonGroup
      nk_toast/        - NKToast

ios/Classes/
  Utilities/           - Color, SF Symbol, Font Swift helpers
  Components/          - One factory + platform view per component
```

Each component uses per-view method channels (`native_kit/{component}_{viewId}`) for reliable multi-instance support.

## License and Attribution

This project is free to use and copy, with a mandatory requirement to credit the author. See the LICENSE file for details.
