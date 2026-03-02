import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class GlassPage extends StatefulWidget {
  const GlassPage({super.key});

  @override
  State<GlassPage> createState() => _GlassPageState();
}

class _GlassPageState extends State<GlassPage> {
  double _tickSlider = 0.5;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // --- NKGlassContainer ---
        _sectionHeader('NKGlassContainer'),
        NKGlassContainer(
          style: NKGlassStyle.regular,
          cornerRadius: 20,
          padding: const EdgeInsets.all(16),
          height: 80,
          child: const Center(
            child:
                Text('Regular glass', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        NKGlassContainer(
          style: NKGlassStyle.clear,
          cornerRadius: 20,
          padding: const EdgeInsets.all(16),
          height: 80,
          child: const Center(
            child: Text('Clear glass', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        NKGlassContainer(
          style: NKGlassStyle.regular,
          capsule: true,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          height: 48,
          child: const Center(
            child: Text('Capsule glass', style: TextStyle(fontSize: 16)),
          ),
        ),

        // --- NKGlassCard ---
        _sectionHeader('NKGlassCard'),
        const NKGlassCard(
          title: 'Settings',
          child: Text('A glass card with a title and content.'),
        ),
        const SizedBox(height: 12),
        NKGlassCard(
          tintColor: Colors.blue,
          child: Row(
            children: [
              const NKIcon(
                  source: NKSFSymbols.heart, size: 24, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Tinted glass card'),
            ],
          ),
        ),

        // --- NKToast ---
        _sectionHeader('NKToast'),
        Row(
          children: [
            Expanded(
              child: NKButton(
                label: 'Top Toast',
                style: NKButtonStyle.glass,
                tintColor: Colors.blue,
                onPressed: () {
                  NKToast.show(
                    context,
                    message: 'Saved successfully!',
                    icon: NKSFSymbol('checkmark.circle.fill'),
                    position: NKToastPosition.top,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NKButton(
                label: 'Bottom Toast',
                style: NKButtonStyle.glass,
                tintColor: Colors.orange,
                onPressed: () {
                  NKToast.show(
                    context,
                    message: 'Item deleted',
                    icon: NKSFSymbol('trash.fill'),
                    position: NKToastPosition.bottom,
                  );
                },
              ),
            ),
          ],
        ),

        // --- NKIcon ---
        _sectionHeader('NKIcon'),
        const Text(
          'SF Symbol rendering modes',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                NKIcon(
                    source: NKSFSymbols.heart, size: 32, color: Colors.red),
                SizedBox(height: 4),
                Text('Mono', style: TextStyle(fontSize: 11)),
              ],
            ),
            Column(
              children: [
                NKIcon(
                  source: NKSFSymbol('cloud.sun.rain.fill'),
                  size: 32,
                  mode: NKSymbolRenderingMode.multicolor,
                ),
                SizedBox(height: 4),
                Text('Multi', style: TextStyle(fontSize: 11)),
              ],
            ),
            Column(
              children: [
                NKIcon(
                  source: NKSFSymbol('person.crop.circle.badge.checkmark'),
                  size: 32,
                  mode: NKSymbolRenderingMode.palette,
                  color: Colors.blue,
                  secondaryColor: Colors.green,
                ),
                SizedBox(height: 4),
                Text('Palette', style: TextStyle(fontSize: 11)),
              ],
            ),
            Column(
              children: [
                NKIcon(
                  source: NKSFSymbol('speaker.wave.3.fill'),
                  size: 32,
                  mode: NKSymbolRenderingMode.hierarchical,
                  color: Colors.blue,
                ),
                SizedBox(height: 4),
                Text('Hierarchy', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Various sizes',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NKIcon(source: NKSFSymbols.star, size: 20, color: Colors.orange),
            NKIcon(source: NKSFSymbols.star, size: 28, color: Colors.orange),
            NKIcon(source: NKSFSymbols.star, size: 36, color: Colors.orange),
            NKIcon(source: NKSFSymbols.star, size: 48, color: Colors.orange),
          ],
        ),

        // --- NKSlider with iOS 26 Ticks ---
        _sectionHeader('NKSlider (iOS 26 Ticks)'),
        Text('Value: ${_tickSlider.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        NKSlider(
          value: _tickSlider,
          numberOfTicks: 5,
          allowsTickValuesOnly: true,
          neutralValue: 0.5,
          onChanged: (v) => setState(() => _tickSlider = v),
          activeColor: Colors.purple,
        ),
        const SizedBox(height: 32),
      ],
    );
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
