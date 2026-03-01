import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  int _badgeCount = 3;

  final List<Widget> _pages = const [
    ComponentGalleryPage(),
    SwitchDemoPage(),
    SliderDemoPage(),
    ButtonDemoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('NativeKit Example'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _incrementBadge,
                tooltip: 'Add Badge',
              ),
            ],
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: NKTabBar(
            items: [
              NKTabBarItem(
                title: 'Gallery',
                icon: NKSFSymbols.house,
                selectedIcon: NKSFSymbols.houseFill,
              ),
              NKTabBarItem(
                title: 'Switch',
                icon: NKSFSymbols.gear,
                selectedIcon: NKSFSymbols.gearFill,
                badge: _badgeCount > 0 ? _badgeCount.toString() : null,
              ),
              NKTabBarItem(
                title: 'Slider',
                icon: NKSFSymbols.star,
                selectedIcon: NKSFSymbols.starFill,
              ),
              NKTabBarItem(
                title: 'Button',
                icon: NKSFSymbols.heart,
                selectedIcon: NKSFSymbols.heartFill,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
        ),
      ),
    );
  }

  void _incrementBadge() {
    setState(() => _badgeCount++);
  }
}

// ---------------------------------------------------------------------------
// Component Gallery Page
// ---------------------------------------------------------------------------

class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Home Page', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('All native_kit components in one place.'),
        const SizedBox(height: 32),

        // NKSegmentedControl
        Text(
          'NKSegmentedControl',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        NKSegmentedControl(
          labels: const ['Day', 'Week', 'Month'],
          selectedIndex: _segmentIndex,
          onValueChanged: (i) => setState(() => _segmentIndex = i),
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        Text('Selected: $_segmentIndex', textAlign: TextAlign.center),
        const SizedBox(height: 32),

        // NKIcon
        Text('NKIcon', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            NKIcon(symbol: NKSFSymbols.heart, size: 32, color: Colors.red),
            NKIcon(symbol: NKSFSymbols.star, size: 32, color: Colors.orange),
            NKIcon(symbol: NKSFSymbols.bell, size: 32, color: Colors.blue),
            NKIcon(
              symbol: NKSFSymbol('cloud.sun.rain.fill'),
              size: 40,
              mode: NKSymbolRenderingMode.multicolor,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // NKPopupMenu
        Text('NKPopupMenu', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
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
          onSelected: (index) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menu item $index selected')),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Switch Demo Page
// ---------------------------------------------------------------------------

class SwitchDemoPage extends StatefulWidget {
  const SwitchDemoPage({super.key});

  @override
  State<SwitchDemoPage> createState() => _SwitchDemoPageState();
}

class _SwitchDemoPageState extends State<SwitchDemoPage> {
  bool _switch1 = true;
  bool _switch2 = false;
  final bool _switch3 = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('NKSwitch', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        _switchRow('Default', _switch1, (v) => setState(() => _switch1 = v)),
        _switchRow(
          'Custom color',
          _switch2,
          (v) => setState(() => _switch2 = v),
          activeColor: Colors.green,
        ),
        _switchRow(
          'Disabled',
          _switch3,
          null,
          enabled: false,
        ),
      ],
    );
  }

  Widget _switchRow(
    String label,
    bool value,
    ValueChanged<bool>? onChanged, {
    Color? activeColor,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          NKSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slider Demo Page
// ---------------------------------------------------------------------------

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _volume = 0.5;
  double _brightness = 75;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('NKSlider', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Text('Continuous: ${_volume.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _volume,
          onChanged: (v) => setState(() => _volume = v),
          activeColor: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text('Stepped (0-100, step 25): ${_brightness.round()}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _brightness,
          min: 0,
          max: 100,
          step: 25,
          onChanged: (v) => setState(() => _brightness = v),
          activeColor: Colors.orange,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Button Demo Page
// ---------------------------------------------------------------------------

class ButtonDemoPage extends StatelessWidget {
  const ButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('NKButton', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        for (final style in NKButtonStyle.values) ...[
          NKButton(
            label: style.name[0].toUpperCase() + style.name.substring(1),
            icon: NKSFSymbols.heart,
            style: style,
            tintColor: Colors.blue,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${style.name} button pressed')),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        const Text('Icon-only buttons:'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NKButton.icon(
              icon: NKSFSymbols.heartFill,
              style: NKButtonStyle.plain,
              tintColor: Colors.red,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbols.starFill,
              style: NKButtonStyle.tinted,
              tintColor: Colors.orange,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbols.bellFill,
              style: NKButtonStyle.filled,
              tintColor: Colors.blue,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
