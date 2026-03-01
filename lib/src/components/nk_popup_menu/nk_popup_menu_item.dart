import '../../models/nk_sf_symbol.dart';

/// Represents a single item in an [NKPopupMenu].
///
/// Each item has a label and optional icon, checked state,
/// and destructive styling.
///
/// Example:
/// ```dart
/// NKPopupMenuItem(
///   label: 'Delete',
///   icon: NKSFSymbols.trash,
///   isDestructive: true,
/// )
/// ```
class NKPopupMenuItem {
  /// The text label displayed for this menu item.
  final String label;

  /// Optional SF Symbol icon displayed alongside the label.
  final NKSFSymbol? icon;

  /// Whether the item shows a checkmark.
  final bool isChecked;

  /// Whether the item is styled as destructive (red text).
  final bool isDestructive;

  const NKPopupMenuItem({
    required this.label,
    this.icon,
    this.isChecked = false,
    this.isDestructive = false,
  });

  /// Converts the item to a map for platform channel communication.
  Map<String, dynamic> toMap() => {
        'label': label,
        if (icon != null) 'icon': icon!.toMap(),
        'isChecked': isChecked,
        'isDestructive': isDestructive,
      };
}

/// A visual separator between groups of menu items.
///
/// Renders as a horizontal divider line in the popup menu.
/// Dividers are not counted when determining the selected item index.
///
/// Example:
/// ```dart
/// NKPopupMenu(
///   items: [
///     NKPopupMenuItem(label: 'Copy'),
///     NKPopupMenuItem(label: 'Paste'),
///     NKPopupMenuDivider(),
///     NKPopupMenuItem(label: 'Delete', isDestructive: true),
///   ],
///   onSelected: (index) => print('Selected: $index'),
/// )
/// ```
class NKPopupMenuDivider extends NKPopupMenuItem {
  const NKPopupMenuDivider() : super(label: '');

  @override
  Map<String, dynamic> toMap() => {'isDivider': true};
}
