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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: NKToolbar(
            title: 'NativeKit',
            tintColor: Colors.blue,
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: NKTabBar(
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
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
