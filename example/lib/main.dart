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
    GlassDemoPage(),
    ToolbarDemoPage(),
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
