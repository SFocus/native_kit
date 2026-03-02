import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final NKSFSymbol icon;
  final VoidCallback onTap;

  const DemoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NKGlassCard(
        child: Row(
          children: [
            NKIcon(source: icon, size: 28, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const NKIcon(
              source: NKSFSymbol('chevron.right'),
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                  NKToast.show(
                    context,
                    message: 'Settings saved!',
                    icon: NKSFSymbol('checkmark.circle.fill'),
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
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Privacy'),
                subtitle: const Text('Control your data sharing'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Storage'),
                subtitle: const Text('Manage device storage'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text('Help & Support'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Rate the App'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
                onTap: () {},
              ),
              ListTile(
                title: const Text('About'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey),
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NKToolbar(
        title: _isEditing ? 'Edit Profile' : 'Profile',
        onBackPressed: () => Navigator.of(context).pop(),
        backButtonTitle: 'Back',
        tintColor: Colors.blue,
        appearance: NKToolbarAppearance.transparent,
        showSeparator: false,
        trailingItems: [
          NKToolbarItem(
            icon: NKSFSymbol('square.and.arrow.up'),
            onPressed: () {
              NKToast.show(
                context,
                message: 'Profile shared!',
                icon: NKSFSymbol('square.and.arrow.up'),
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
              source: NKSFSymbols.personFill,
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

class DetailScreen extends StatelessWidget {
  final int depth;

  const DetailScreen({super.key, required this.depth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NKToolbar(
        title: 'Screen $depth',
        onBackPressed: () => Navigator.of(context).pop(),
        backButtonTitle: depth == 1 ? 'Back' : 'Screen ${depth - 1}',
        tintColor: Colors.blue,
        trailingItems: [
          NKToolbarItem(
            icon: NKSFSymbol('info.circle'),
            onPressed: () {
              NKToast.show(
                context,
                message: 'Info for screen $depth',
                icon: NKSFSymbol('info.circle'),
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
              source: NKSFSymbol('square.stack.3d.up'),
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
                label: 'Go Deeper \u2192 Screen ${depth + 1}',
                icon: NKSFSymbol('arrow.right'),
                style: NKButtonStyle.filled,
                tintColor: Colors.blue,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(depth: depth + 1),
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

class CustomFontToolbarScreen extends StatefulWidget {
  final bool useTheme;
  const CustomFontToolbarScreen({super.key, required this.useTheme});

  @override
  State<CustomFontToolbarScreen> createState() =>
      _CustomFontToolbarScreenState();
}

class _CustomFontToolbarScreenState extends State<CustomFontToolbarScreen> {
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
                  NKToast.show(
                    context,
                    message: 'Title uses Pacifico, body uses Inter',
                    icon: NKSFSymbol('textformat'),
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
              for (int i = 0; i < 10; i++) ...[
                const Divider(),
                ListTile(
                  title: Text('Item ${i + 1}'),
                  subtitle: const Text('Demonstrates scrollable content'),
                  trailing: const NKIcon(
                    source: NKSFSymbol('chevron.right'),
                    size: 16,
                    color: Colors.grey,
                  ),
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
