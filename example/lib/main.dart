import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

import 'pages/controls_page.dart';
import 'pages/actions_page.dart';
import 'pages/glass_page.dart';
import 'pages/customize_page.dart';

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
  bool _isDark = false;

  final List<Widget> _pages = const [
    ControlsPage(),
    ActionsPage(),
    GlassPage(),
    CustomizePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: _isDark ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final tabBarHeight = 49.0 + bottomPadding;

          return Scaffold(
            appBar: NKToolbar(
              title: 'NativeKit',
              tintColor: Colors.blue,
              trailingItems: [
                NKToolbarItem(
                  icon: NKSFSymbol(_isDark ? 'sun.max.fill' : 'moon.fill'),
                  onPressed: () {
                    setState(() => _isDark = !_isDark);
                    NativeKit.setUserInterfaceStyle(
                      _isDark ? Brightness.dark : Brightness.light,
                    );
                  },
                ),
                NKToolbarItem(
                  icon: NKSFSymbol('arrow.right.square'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _TestNavPage(),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                // Page content with bottom padding for the tab bar
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: tabBarHeight),
                    child: _pages[_selectedIndex],
                  ),
                ),
                // Tab bar as overlay at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: NKTabBar(
                    items: [
                      NKTabBarItem(
                        title: 'Controls',
                        icon: NKSFSymbol('slider.horizontal.3'),
                        selectedIcon: NKSFSymbol('slider.horizontal.3'),
                      ),
                      NKTabBarItem(
                        title: 'Actions',
                        icon: NKSFSymbol('hand.tap'),
                        selectedIcon: NKSFSymbol('hand.tap.fill'),
                      ),
                      NKTabBarItem(
                        title: 'Glass',
                        icon: NKSFSymbol('sparkles'),
                        selectedIcon: NKSFSymbol('sparkles'),
                      ),
                      NKTabBarItem(
                        title: 'Customize',
                        icon: NKSFSymbol('paintbrush'),
                        selectedIcon: NKSFSymbol('paintbrush.fill'),
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    backgroundColor: _isDark ? Colors.black : null,
                    selectedItemColor: Colors.blue,
                    unselectedItemColor: Colors.grey,
                    onTap: (index) => setState(() => _selectedIndex = index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Simple page to test navigate-and-back with the tab bar.
class _TestNavPage extends StatelessWidget {
  const _TestNavPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NKToolbar(
        title: 'Test Page',
        onBackPressed: () => Navigator.of(context).pop(),
        tintColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Navigate back to check tab bar appearance'),
      ),
    );
  }
}
