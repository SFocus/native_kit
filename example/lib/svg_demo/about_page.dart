import 'package:flutter/material.dart';

class SvgAboutPage extends StatelessWidget {
  const SvgAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'How SVG \u2192 Native works',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _StepTile(
          step: '1',
          title: 'SVG asset',
          body: 'SVG files live in your assets folder (e.g., assets/svg/home.svg), '
              'just like in any Flutter app.',
        ),
        const _StepTile(
          step: '2',
          title: 'Parse to Picture',
          body: 'flutter_svg loads and parses the SVG asset into a dart:ui '
              'Picture via vg.loadPicture(SvgAssetLoader(...)).',
        ),
        const _StepTile(
          step: '3',
          title: 'Render to PNG bytes',
          body: 'NKImageData.fromPicture() renders the Picture to a '
              'raster image at the device pixel ratio, then encodes as PNG.',
        ),
        const _StepTile(
          step: '4',
          title: 'Send to iOS',
          body: 'PNG bytes are sent over the Flutter method channel as '
              'Uint8List (FlutterStandardTypedData on Swift side).',
        ),
        const _StepTile(
          step: '5',
          title: 'Display natively',
          body: 'Swift creates UIImage(data:scale:) from the bytes and '
              'displays it in the native UIKit component.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'The conversion happens once at load time. The resulting '
            'NKImageData is a lightweight Uint8List that can be reused '
            'across multiple components without re-rendering.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final String title;
  final String body;

  const _StepTile({
    required this.step,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.deepPurple,
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
