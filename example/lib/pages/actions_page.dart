import 'package:flutter/material.dart';
import 'package:native_kit/native_kit.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // --- Standard Buttons ---
        _sectionHeader('Standard Buttons'),
        for (final style in [
          NKButtonStyle.plain,
          NKButtonStyle.gray,
          NKButtonStyle.tinted,
          NKButtonStyle.bordered,
          NKButtonStyle.borderedProminent,
          NKButtonStyle.filled,
        ]) ...[
          NKButton(
            label: style.name[0].toUpperCase() + style.name.substring(1),
            icon: NKSFSymbols.heart,
            style: style,
            tintColor: Colors.blue,
            onPressed: () {
              NKToast.show(
                context,
                message: '${style.name} pressed',
                icon: NKSFSymbol('checkmark.circle.fill'),
              );
            },
          ),
          const SizedBox(height: 10),
        ],

        // --- Glass Buttons ---
        _sectionHeader('Glass Buttons'),
        for (final style in [
          NKButtonStyle.glass,
          NKButtonStyle.clearGlass,
          NKButtonStyle.prominentGlass,
          NKButtonStyle.prominentClearGlass,
        ]) ...[
          NKButton(
            label: style.name[0].toUpperCase() + style.name.substring(1),
            icon: NKSFSymbol('sparkles'),
            style: style,
            tintColor: Colors.blue,
            onPressed: () {
              NKToast.show(
                context,
                message: '${style.name} pressed',
                icon: NKSFSymbol('sparkles'),
              );
            },
          ),
          const SizedBox(height: 10),
        ],

        // --- Icon-Only Buttons ---
        _sectionHeader('Icon Buttons'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NKButton.icon(
              icon: NKSFSymbols.heartFill,
              style: NKButtonStyle.glass,
              tintColor: Colors.red,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbols.starFill,
              style: NKButtonStyle.prominentGlass,
              tintColor: Colors.orange,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbols.bellFill,
              style: NKButtonStyle.filled,
              tintColor: Colors.blue,
              onPressed: () {},
            ),
            NKButton.icon(
              icon: NKSFSymbol('square.and.arrow.up'),
              style: NKButtonStyle.bordered,
              tintColor: Colors.green,
              onPressed: () {},
            ),
          ],
        ),

        // --- NKPopupMenu ---
        _sectionHeader('NKPopupMenu'),
        NKPopupMenu(
          buttonLabel: 'Options',
          buttonIcon: NKSFSymbol('ellipsis.circle'),
          items: [
            NKPopupMenuItem(label: 'Edit', icon: NKSFSymbol('pencil')),
            NKPopupMenuItem(
                label: 'Share', icon: NKSFSymbol('square.and.arrow.up')),
            const NKPopupMenuDivider(),
            NKPopupMenuItem(
              label: 'Delete',
              icon: NKSFSymbol('trash'),
              isDestructive: true,
            ),
          ],
          onSelected: (index) {
            NKToast.show(
              context,
              message: 'Menu item $index selected',
              icon: NKSFSymbol('checkmark'),
            );
          },
        ),

        // --- NKGlassButtonGroup ---
        _sectionHeader('NKGlassButtonGroup'),
        NKGlassButtonGroup(
          spacing: 12.0,
          buttons: [
            NKGlassButton(
              label: 'Like',
              icon: NKSFSymbols.heart,
              onPressed: () => NKToast.show(
                context,
                message: 'Liked!',
                icon: NKSFSymbols.heartFill,
              ),
            ),
            NKGlassButton(
              label: 'Share',
              icon: NKSFSymbol('square.and.arrow.up'),
              onPressed: () => NKToast.show(
                context,
                message: 'Shared!',
                icon: NKSFSymbol('square.and.arrow.up'),
              ),
            ),
            NKGlassButton(
              label: 'Save',
              icon: NKSFSymbol('bookmark'),
              onPressed: () => NKToast.show(
                context,
                message: 'Saved!',
                icon: NKSFSymbol('bookmark.fill'),
              ),
            ),
          ],
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
