import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class SvgIconsPage extends StatelessWidget {
  final Map<String, NKImageData> icons;
  const SvgIconsPage({super.key, required this.icons});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'NKIcon with SVG images',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'SVG assets loaded from assets/svg/, converted to PNG via '
          'NKImageData.fromPicture(), then displayed in native UIImageView.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _iconWithLabel(icons['home']!, 'Home', 32),
            _iconWithLabel(icons['search']!, 'Search', 32),
            _iconWithLabel(icons['heart']!, 'Heart', 32),
            _iconWithLabel(icons['settings']!, 'Settings', 32),
            _iconWithLabel(icons['user']!, 'User', 32),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Larger SVG icons (48pt)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NKIcon(source: icons['home']!, size: 48),
            NKIcon(source: icons['heart']!, size: 48),
            NKIcon(source: icons['settings']!, size: 48),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'SVG vs SF Symbol comparison',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  NKIcon(source: icons['heart']!, size: 40),
                  const SizedBox(height: 4),
                  const Text('SVG heart', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                children: [
                  NKIcon(
                    source: NKSFSymbols.heartFill,
                    size: 40,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4),
                  Text('SF Symbol', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  NKIcon(source: icons['home']!, size: 40),
                  const SizedBox(height: 4),
                  const Text('SVG home', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                children: [
                  NKIcon(
                    source: NKSFSymbols.houseFill,
                    size: 40,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4),
                  Text('SF Symbol', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconWithLabel(NKImageData icon, String label, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NKIcon(source: icon, size: size),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
