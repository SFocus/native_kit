import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class SvgMenuPage extends StatelessWidget {
  final Map<String, NKImageData> icons;
  const SvgMenuPage({super.key, required this.icons});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'NKPopupMenu with SVG icons',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: NKPopupMenu(
            buttonLabel: 'SVG Menu',
            buttonIcon: icons['settings']!,
            items: [
              NKPopupMenuItem(label: 'Home', icon: icons['home']!),
              NKPopupMenuItem(label: 'Search', icon: icons['search']!),
              const NKPopupMenuDivider(),
              NKPopupMenuItem(label: 'Settings', icon: icons['settings']!),
            ],
            onSelected: (index) {
              debugPrint('Selected menu item: $index');
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'NKToast with SVG icon',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        NKButton(
          label: 'Show Toast',
          icon: icons['heart']!,
          style: NKButtonStyle.filled,
          onPressed: () {
            NKToast.show(
              context,
              message: 'SVG icon in a toast!',
              icon: icons['heart']!,
            );
          },
        ),
      ],
    );
  }
}
