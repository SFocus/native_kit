import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

import '../svg_demo_page.dart';
import 'toolbar_page.dart';

class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key});

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
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
        // --- NKTheme ---
        _sectionHeader('NKTheme'),
        Row(
          children: [
            const Text('Global theme (Inter):'),
            const Spacer(),
            NKSwitch(
              value: _useTheme,
              onChanged: (v) => setState(() => _useTheme = v),
              activeColor: Colors.indigo,
            ),
          ],
        ),

        // --- Custom Fonts ---
        _sectionHeader('Custom Fonts'),
        NKSegmentedControl(
          labels: const ['Day', 'Week', 'Month', 'Year'],
          selectedIndex: _segmentIndex,
          onValueChanged: (i) => setState(() => _segmentIndex = i),
          tintColor: Colors.indigo,
          cornerRadius: 14,
        ),
        const SizedBox(height: 16),
        NKButton(
          label: 'Inter Button',
          icon: NKSFSymbols.heart,
          style: NKButtonStyle.filled,
          tintColor: Colors.indigo,
          cornerRadius: 14,
          onPressed: () => NKToast.show(
            context,
            message: 'Inter font',
            icon: NKSFSymbol('textformat'),
          ),
        ),
        const SizedBox(height: 10),
        NKButton(
          label: 'Pacifico Button',
          icon: NKSFSymbols.star,
          style: NKButtonStyle.borderedProminent,
          tintColor: Colors.deepPurple,
          textStyle: _pacificoStyle,
          cornerRadius: 20,
          onPressed: () => NKToast.show(
            context,
            message: 'Pacifico font',
            icon: NKSFSymbol('textformat'),
          ),
        ),
        const SizedBox(height: 10),
        NKButton(
          label: 'Playfair Button',
          icon: NKSFSymbols.heart,
          style: NKButtonStyle.filled,
          tintColor: Colors.teal,
          textStyle: _playfairStyle,
          cornerRadius: 14,
          onPressed: () => NKToast.show(
            context,
            message: 'Playfair font',
            icon: NKSFSymbol('textformat'),
          ),
        ),
        const SizedBox(height: 10),
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

        // --- NKProgressView with corner radius ---
        _sectionHeader('NKProgressView'),
        const Text(
          'Corner radius: 6 (theme: 14)',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
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
                () => _progress = (_progress + 0.1).clamp(0.0, 1.0),
              ),
              child: const Text('+10%'),
            ),
            TextButton(
              onPressed: () => setState(() => _progress = 0.0),
              child: const Text('Reset'),
            ),
          ],
        ),

        // --- NKToolbar ---
        _sectionHeader('NKToolbar'),
        const Text(
          'Tap to see native navigation bars',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        DemoCard(
          title: 'Settings Screen',
          subtitle: 'Large title + Done action',
          icon: NKSFSymbols.gear,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 8),
        DemoCard(
          title: 'Profile Screen',
          subtitle: 'Transparent bar + Edit & Share',
          icon: NKSFSymbols.person,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(height: 8),
        DemoCard(
          title: 'Custom Font Toolbar',
          subtitle: 'Pacifico title + theme body',
          icon: NKSFSymbol('textformat.size'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  CustomFontToolbarScreen(useTheme: _useTheme),
            ),
          ),
        ),

        // --- Custom Images / SVG ---
        _sectionHeader('Custom Images'),
        const Text(
          'SVG and PNG images in native components via NKImageData',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        DemoCard(
          title: 'SVG Demo',
          subtitle: 'SVG icons in NK components',
          icon: NKSFSymbol('photo'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SvgDemoScreen()),
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
}

Widget _sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
