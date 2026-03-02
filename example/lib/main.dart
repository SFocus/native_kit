import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register custom fonts with native iOS so UIKit views can use them.
  await NKFontLoader.registerFonts([
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/PlayfairDisplay-Regular.ttf',
    'assets/fonts/PlayfairDisplay-Bold.ttf',
    'assets/fonts/Pacifico-Regular.ttf',
  ]);

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
    GlassDemoPage(),
    ToolbarDemoPage(),
    PickerDemoPage(),
    CustomFontDemoPage(),
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
              NKTabBarItem(
                title: 'Glass',
                icon: NKSFSymbol('sparkles'),
                selectedIcon: NKSFSymbol('sparkles'),
              ),
              NKTabBarItem(
                title: 'Toolbar',
                icon: NKSFSymbol('menubar.rectangle'),
                selectedIcon: NKSFSymbol('menubar.rectangle'),
              ),
              NKTabBarItem(
                title: 'Pickers',
                icon: NKSFSymbol('calendar'),
                selectedIcon: NKSFSymbol('calendar'),
              ),
              NKTabBarItem(
                title: 'Fonts',
                icon: NKSFSymbol('textformat'),
                selectedIcon: NKSFSymbol('textformat'),
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
              style: NKButtonStyle.glass,
              tintColor: Colors.red,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbols.starFill,
              style: NKButtonStyle.prominentGlass,
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

// ---------------------------------------------------------------------------
// Glass Demo Page
// ---------------------------------------------------------------------------

class GlassDemoPage extends StatefulWidget {
  const GlassDemoPage({super.key});

  @override
  State<GlassDemoPage> createState() => _GlassDemoPageState();
}

class _GlassDemoPageState extends State<GlassDemoPage> {
  double _tickSlider = 0.5;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Liquid Glass',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),

        // NKGlassContainer
        Text('NKGlassContainer',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKGlassContainer(
          style: NKGlassStyle.regular,
          cornerRadius: 20,
          padding: const EdgeInsets.all(16),
          height: 80,
          child: const Center(
            child: Text('Regular glass container',
                style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        NKGlassContainer(
          style: NKGlassStyle.clear,
          capsule: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          height: 48,
          child: const Center(
            child: Text('Capsule glass', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),

        // NKGlassCard
        Text('NKGlassCard', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const NKGlassCard(
          title: 'Settings',
          child: Text('A glass card with a title and content.'),
        ),
        const SizedBox(height: 12),
        NKGlassCard(
          tintColor: Colors.blue,
          child: Row(
            children: [
              const NKIcon(
                  symbol: NKSFSymbols.heart, size: 24, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Tinted glass card'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // NKGlassButtonGroup
        Text('NKGlassButtonGroup',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKGlassButtonGroup(
          spacing: 12.0,
          buttons: [
            NKGlassButton(
              label: 'Like',
              icon: NKSFSymbols.heart,
              onPressed: () => _showSnack(context, 'Liked!'),
            ),
            NKGlassButton(
              label: 'Share',
              icon: NKSFSymbol('square.and.arrow.up'),
              onPressed: () => _showSnack(context, 'Shared!'),
            ),
            NKGlassButton(
              label: 'Save',
              icon: NKSFSymbol('bookmark'),
              onPressed: () => _showSnack(context, 'Saved!'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // NKToast
        Text('NKToast', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKButton(
          label: 'Show Toast',
          style: NKButtonStyle.glass,
          tintColor: Colors.blue,
          onPressed: () {
            NKToast.show(
              context,
              message: 'Item saved successfully!',
              icon: NKSFSymbol('checkmark.circle.fill'),
            );
          },
        ),
        const SizedBox(height: 32),

        // NKSlider with ticks
        Text('NKSlider (iOS 26 Ticks)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text('Tick slider: ${_tickSlider.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _tickSlider,
          numberOfTicks: 5,
          allowsTickValuesOnly: true,
          neutralValue: 0.5,
          onChanged: (v) => setState(() => _tickSlider = v),
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ---------------------------------------------------------------------------
// Toolbar Demo Page
// ---------------------------------------------------------------------------

class ToolbarDemoPage extends StatelessWidget {
  const ToolbarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('NKToolbar', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Native navigation bar with title, back button, and actions. '
          'Tap a card to open a screen.',
        ),
        const SizedBox(height: 24),
        _DemoCard(
          title: 'Settings Screen',
          subtitle: 'Large title + Back + Done action',
          icon: NKSFSymbols.gear,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const _SettingsScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _DemoCard(
          title: 'Profile Screen',
          subtitle: 'Transparent bar + Edit & Share',
          icon: NKSFSymbols.person,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const _ProfileScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _DemoCard(
          title: 'Detail → Sub-detail',
          subtitle: 'Multi-level nav with back button titles',
          icon: NKSFSymbol('arrow.right.arrow.left'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const _DetailScreen(depth: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final NKSFSymbol icon;
  final VoidCallback onTap;

  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: NKIcon(symbol: icon, size: 28, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Screen — back button + trailing "Done" action
// ---------------------------------------------------------------------------

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _analytics = true;
  bool _autoUpdate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverNKToolbar(
            title: 'Settings',
            onBackPressed: () => Navigator.of(context).pop(),
            tintColor: Colors.blue,
            trailingItems: [
              NKToolbarItem(
                label: 'Done',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved!')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark appearance'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              SwitchListTile(
                title: const Text('Analytics'),
                subtitle: const Text('Share usage data'),
                value: _analytics,
                onChanged: (v) => setState(() => _analytics = v),
              ),
              SwitchListTile(
                title: const Text('Auto-Update'),
                subtitle: const Text('Download updates automatically'),
                value: _autoUpdate,
                onChanged: (v) => setState(() => _autoUpdate = v),
              ),
              const Divider(),
              ListTile(
                title: const Text('Account'),
                subtitle: const Text('Manage your account settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Privacy'),
                subtitle: const Text('Control your data sharing'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Storage'),
                subtitle: const Text('Manage device storage'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Rate the App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Scroll to see the large title collapse',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Screen — back button + Edit & Share trailing actions
// ---------------------------------------------------------------------------

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen();

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NKToolbar(
        title: _isEditing ? 'Edit Profile' : 'Profile',
        onBackPressed: () => Navigator.of(context).pop(),
        backButtonTitle: 'Toolbar',
        tintColor: Colors.blue,
        appearance: NKToolbarAppearance.transparent,
        showSeparator: false,
        trailingItems: [
          NKToolbarItem(
            icon: NKSFSymbol('square.and.arrow.up'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile shared!')),
              );
            },
          ),
          NKToolbarItem(
            icon: NKSFSymbol(_isEditing ? 'checkmark' : 'pencil'),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NKIcon(
              symbol: NKSFSymbols.personFill,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'John Appleseed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing ? 'Editing...' : 'john@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            if (_isEditing) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Display Name',
                    hintText: 'John Appleseed',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'john@example.com',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Screen — multi-level push navigation
// ---------------------------------------------------------------------------

class _DetailScreen extends StatelessWidget {
  final int depth;

  const _DetailScreen({required this.depth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NKToolbar(
        title: 'Screen $depth',
        onBackPressed: () => Navigator.of(context).pop(),
        backButtonTitle: depth == 1 ? 'Toolbar' : 'Screen ${depth - 1}',
        tintColor: Colors.blue,
        trailingItems: [
          NKToolbarItem(
            icon: NKSFSymbol('info.circle'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Info for screen $depth')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NKIcon(
              symbol: NKSFSymbol('square.stack.3d.up'),
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Screen $depth',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Navigation depth: $depth',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            if (depth < 5)
              NKButton(
                label: 'Go Deeper → Screen ${depth + 1}',
                icon: NKSFSymbol('arrow.right'),
                style: NKButtonStyle.filled,
                tintColor: Colors.blue,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _DetailScreen(depth: depth + 1),
                  ),
                ),
              ),
            if (depth >= 5)
              const Text(
                'Max depth reached!',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Picker Demo Page — NKDatePicker, NKProgressView, NKSheet
// ---------------------------------------------------------------------------

class PickerDemoPage extends StatefulWidget {
  const PickerDemoPage({super.key});

  @override
  State<PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<PickerDemoPage> {
  DateTime _selectedDate = DateTime.now();
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Pickers & More',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),

        // NKProgressView — bar
        Text('NKProgressView (bar)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKProgressView(
          style: NKProgressViewStyle.bar,
          value: _progress,
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Progress: ${(_progress * 100).round()}%'),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  setState(() => _progress = (_progress + 0.1).clamp(0.0, 1.0)),
              child: const Text('+10%'),
            ),
            TextButton(
              onPressed: () => setState(() => _progress = 0.0),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // NKProgressView — spinner
        Text('NKProgressView (spinner)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.small,
                ),
                SizedBox(height: 4),
                Text('Small'),
              ],
            ),
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.medium,
                ),
                SizedBox(height: 4),
                Text('Medium'),
              ],
            ),
            Column(
              children: [
                NKProgressView(
                  style: NKProgressViewStyle.spinner,
                  spinnerSize: NKSpinnerSize.large,
                  tintColor: Colors.orange,
                ),
                SizedBox(height: 4),
                Text('Large'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // NKDatePicker — compact
        Text('NKDatePicker (compact)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKDatePicker(
          mode: NKDatePickerMode.dateAndTime,
          style: NKDatePickerStyle.compact,
          initialDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: 8),
        Text('Selected: ${_selectedDate.toString().split('.').first}'),
        const SizedBox(height: 24),

        // NKDatePicker — inline
        Text('NKDatePicker (inline)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        NKDatePicker(
          mode: NKDatePickerMode.date,
          style: NKDatePickerStyle.inline,
          initialDate: _selectedDate,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          tintColor: Colors.blue,
        ),
        const SizedBox(height: 32),

      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Font Demo Page
// ---------------------------------------------------------------------------

class CustomFontDemoPage extends StatefulWidget {
  const CustomFontDemoPage({super.key});

  @override
  State<CustomFontDemoPage> createState() => _CustomFontDemoPageState();
}

class _CustomFontDemoPageState extends State<CustomFontDemoPage> {
  int _segmentIndex = 0;
  double _progress = 0.65;
  bool _useTheme = true;

  static const _interStyle = NKTextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: NKFontWeight.semibold,
  );

  static const _playfairStyle = NKTextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 16,
    fontWeight: NKFontWeight.bold,
  );

  static const _pacificoStyle = NKTextStyle(
    fontFamily: 'Pacifico',
    fontSize: 16,
    fontWeight: NKFontWeight.regular,
  );

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Custom Fonts',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'All components below use fonts registered via NKFontLoader '
          'and styled through NKTheme / per-component overrides.',
        ),
        const SizedBox(height: 16),

        // Theme toggle
        Row(
          children: [
            const Text('NKTheme (Inter):'),
            const Spacer(),
            NKSwitch(
              value: _useTheme,
              onChanged: (v) => setState(() => _useTheme = v),
              activeColor: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- NKSegmentedControl ---
        Text('NKSegmentedControl',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Using theme font (Inter) via NKTheme'),
        const SizedBox(height: 8),
        NKSegmentedControl(
          labels: const ['Day', 'Week', 'Month', 'Year'],
          selectedIndex: _segmentIndex,
          onValueChanged: (i) => setState(() => _segmentIndex = i),
          tintColor: Colors.indigo,
          cornerRadius: 14,
        ),
        const SizedBox(height: 32),

        // --- NKButton with theme font ---
        Text('NKButton', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Theme font (Inter) — inherited from NKTheme'),
        const SizedBox(height: 8),
        NKButton(
          label: 'Inter Button',
          icon: NKSFSymbols.heart,
          style: NKButtonStyle.filled,
          tintColor: Colors.indigo,
          cornerRadius: 14,
          onPressed: () => _showSnack(context, 'Inter button pressed'),
        ),
        const SizedBox(height: 16),
        const Text('Per-component override (Pacifico — handwriting)'),
        const SizedBox(height: 8),
        NKButton(
          label: 'Pacifico Button',
          icon: NKSFSymbols.star,
          style: NKButtonStyle.borderedProminent,
          tintColor: Colors.deepPurple,
          textStyle: _pacificoStyle,
          cornerRadius: 20,
          onPressed: () => _showSnack(context, 'Pacifico button pressed'),
        ),
        const SizedBox(height: 8),
        NKButton(
          label: 'Playfair Button',
          icon: NKSFSymbols.heart,
          style: NKButtonStyle.filled,
          tintColor: Colors.teal,
          textStyle: _playfairStyle,
          cornerRadius: 14,
          onPressed: () => _showSnack(context, 'Playfair button pressed'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NKButton(
                label: 'Glass',
                style: NKButtonStyle.glass,
                tintColor: Colors.indigo,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NKButton(
                label: 'Tinted',
                style: NKButtonStyle.tinted,
                tintColor: Colors.indigo,
                textStyle: const NKTextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: NKFontWeight.bold,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NKButton(
                label: 'Gray',
                style: NKButtonStyle.gray,
                textStyle: _pacificoStyle,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // --- NKProgressView with corner radius ---
        Text('NKProgressView',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Corner radius: 6 (theme: 14)'),
        const SizedBox(height: 8),
        NKProgressView(
          style: NKProgressViewStyle.bar,
          value: _progress,
          tintColor: Colors.indigo,
          cornerRadius: 6,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${(_progress * 100).round()}%'),
            const Spacer(),
            TextButton(
              onPressed: () => setState(
                  () => _progress = (_progress + 0.1).clamp(0.0, 1.0)),
              child: const Text('+10%'),
            ),
            TextButton(
              onPressed: () => setState(() => _progress = 0.0),
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NKProgressView(
              style: NKProgressViewStyle.spinner,
              spinnerSize: NKSpinnerSize.medium,
              tintColor: Colors.indigo,
            ),
            NKProgressView(
              style: NKProgressViewStyle.spinner,
              spinnerSize: NKSpinnerSize.large,
              tintColor: Colors.deepPurple,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // --- Toolbar demo with custom font ---
        Text('NKToolbar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('Tap to see toolbar with Pacifico title'),
        const SizedBox(height: 8),
        _DemoCard(
          title: 'Pacifico Toolbar',
          subtitle: 'Handwriting title font + theme body',
          icon: NKSFSymbol('textformat.size'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _CustomFontToolbarScreen(useTheme: _useTheme),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );

    if (_useTheme) {
      return NKTheme(
        data: const NKThemeData(
          textStyle: _interStyle,
          cornerRadius: 14,
          tintColor: Colors.indigo,
        ),
        child: body,
      );
    }
    return body;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ---------------------------------------------------------------------------
// Custom Font Toolbar Screen
// ---------------------------------------------------------------------------

class _CustomFontToolbarScreen extends StatefulWidget {
  final bool useTheme;
  const _CustomFontToolbarScreen({required this.useTheme});

  @override
  State<_CustomFontToolbarScreen> createState() =>
      _CustomFontToolbarScreenState();
}

class _CustomFontToolbarScreenState extends State<_CustomFontToolbarScreen> {
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverNKToolbar(
            title: 'Custom Fonts',
            onBackPressed: () => Navigator.of(context).pop(),
            tintColor: Colors.indigo,
            titleTextStyle: const NKTextStyle(
              fontFamily: 'Pacifico',
              fontSize: 34,
              fontWeight: NKFontWeight.regular,
            ),
            trailingItems: [
              NKToolbarItem(
                icon: NKSFSymbol('info.circle'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Title uses Pacifico, body uses Inter')),
                  );
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: NKSegmentedControl(
                  labels: const ['Overview', 'Details', 'Stats'],
                  selectedIndex: _segmentIndex,
                  onValueChanged: (i) => setState(() => _segmentIndex = i),
                  cornerRadius: 14,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: NKButton(
                  label: 'Action Button (Inter)',
                  icon: NKSFSymbols.heart,
                  style: NKButtonStyle.filled,
                  cornerRadius: 14,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: NKButton(
                  label: 'Pacifico Override',
                  icon: NKSFSymbols.star,
                  style: NKButtonStyle.tinted,
                  textStyle: const NKTextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 16,
                    fontWeight: NKFontWeight.regular,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: NKProgressView(
                  style: NKProgressViewStyle.bar,
                  value: 0.75,
                  cornerRadius: 6,
                ),
              ),
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Scroll up to see the large title collapse',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              // Extra space for scrolling
              for (int i = 0; i < 10; i++) ...[
                const Divider(),
                ListTile(
                  title: Text('Item ${i + 1}'),
                  subtitle: const Text('Demonstrates scrollable content'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );

    if (widget.useTheme) {
      return NKTheme(
        data: const NKThemeData(
          textStyle: NKTextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: NKFontWeight.semibold,
          ),
          cornerRadius: 14,
          tintColor: Colors.indigo,
        ),
        child: content,
      );
    }
    return content;
  }
}
