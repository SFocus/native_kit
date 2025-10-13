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

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const HomePage(), // Placeholder for center button
    const ProfilePage(),
    const SettingsPage(),
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
                title: 'Home',
                icon: NKSFSymbols.house,
                selectedIcon: NKSFSymbols.houseFill,
              ),
              NKTabBarItem(
                title: 'Search',
                icon: NKSFSymbols.magnifyingglass,
                badge: _badgeCount > 0 ? _badgeCount.toString() : null,
              ),
              NKTabBarItem(
                title: 'Profile',
                icon: NKSFSymbols.person,
                selectedIcon: NKSFSymbols.personFill,
              ),
              NKTabBarItem(
                title: 'Settings',
                icon: NKSFSymbols.gear,
              ),
              // Custom center button (like Instagram/TikTok)
              NKTabBarItem.customButton(
                icon: NKSFSymbols.plus,
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
            onCustomButtonTap: (index) {
              _showCreateDialog(context);
            },
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    // Example: show a dialog when custom button is tapped
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Content'),
        content: const Text(
            '🎉 Custom button tapped!\n\nThis could open a camera, create post dialog, or any custom action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _incrementBadge() {
    setState(() {
      _badgeCount++;
    });
  }
}

// Demo Pages

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Home Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Tap the button below to show the native iOS bottom navigation bar!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Search Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Profile Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Settings Page',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
