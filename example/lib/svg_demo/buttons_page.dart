import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class SvgButtonsPage extends StatelessWidget {
  final Map<String, NKImageData> icons;
  const SvgButtonsPage({super.key, required this.icons});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'NKButton with SVG icons',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        NKButton(
          label: 'Home',
          icon: icons['home']!,
          style: NKButtonStyle.filled,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        NKButton(
          label: 'Search',
          icon: icons['search']!,
          style: NKButtonStyle.tinted,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        NKButton(
          label: 'Settings',
          icon: icons['settings']!,
          style: NKButtonStyle.bordered,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        NKButton.icon(
          icon: icons['heart']!,
          style: NKButtonStyle.borderedProminent,
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        const Text(
          'NKGlassButtonGroup with SVG',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: NKGlassButtonGroup(
            buttons: [
              NKGlassButton(
                icon: icons['heart']!,
                label: 'Like',
                onPressed: () {},
              ),
              NKGlassButton(
                icon: icons['settings']!,
                label: 'Settings',
                onPressed: () {},
              ),
              NKGlassButton(
                icon: icons['user']!,
                label: 'Profile',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
