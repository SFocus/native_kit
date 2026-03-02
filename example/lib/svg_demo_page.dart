import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

import 'svg_demo/svg_helpers.dart';
import 'svg_demo/icons_page.dart';
import 'svg_demo/buttons_page.dart';
import 'svg_demo/menu_page.dart';
import 'svg_demo/about_page.dart';

class SvgDemoScreen extends StatefulWidget {
  const SvgDemoScreen({super.key});

  @override
  State<SvgDemoScreen> createState() => _SvgDemoScreenState();
}

class _SvgDemoScreenState extends State<SvgDemoScreen> {
  int _selectedIndex = 0;
  Map<String, NKImageData>? _icons;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadIcons();
    }
  }

  Future<void> _loadIcons() async {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final icons = await loadSvgAssetIcons(
      {
        'home': 'assets/svg/home.svg',
        'search': 'assets/svg/search.svg',
        'heart': 'assets/svg/heart.svg',
        'settings': 'assets/svg/settings.svg',
        'user': 'assets/svg/user.svg',
      },
      size: 24.0,
      devicePixelRatio: dpr,
    );
    if (mounted) {
      setState(() => _icons = icons);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_icons == null) {
      return Scaffold(
        appBar: NKToolbar(
          title: 'SVG Icons Demo',
          onBackPressed: () => Navigator.of(context).pop(),
          tintColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final icons = _icons!;

    return Scaffold(
      appBar: NKToolbar(
        title: 'SVG Icons Demo',
        onBackPressed: () => Navigator.of(context).pop(),
        tintColor: Colors.deepPurple,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SvgIconsPage(icons: icons),
          SvgButtonsPage(icons: icons),
          SvgMenuPage(icons: icons),
          const SvgAboutPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: NKTabBar(
          items: [
            NKTabBarItem(title: 'Icons', icon: icons['home']!),
            NKTabBarItem(title: 'Buttons', icon: icons['search']!),
            NKTabBarItem(title: 'Menu', icon: icons['settings']!),
            NKTabBarItem(title: 'About', icon: icons['user']!),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
