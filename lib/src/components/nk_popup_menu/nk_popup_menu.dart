import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../../models/nk_image_source.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';
import 'nk_popup_menu_item.dart';

/// A native iOS popup menu (context menu) widget.
///
/// Uses UIKit's UIMenu attached to a UIButton on iOS for an authentic
/// native popup menu experience. Falls back to a CupertinoActionSheet
/// on other platforms.
///
/// The menu is shown as the button's primary action (long-press or tap).
///
/// Example:
/// ```dart
/// NKPopupMenu(
///   buttonLabel: 'Options',
///   buttonIcon: NKSFSymbols.ellipsisCircle,
///   items: [
///     NKPopupMenuItem(label: 'Edit', icon: NKSFSymbols.pencil),
///     NKPopupMenuItem(label: 'Share', icon: NKSFSymbols.share),
///     NKPopupMenuDivider(),
///     NKPopupMenuItem(
///       label: 'Delete',
///       icon: NKSFSymbols.trash,
///       isDestructive: true,
///     ),
///   ],
///   onSelected: (index) => print('Selected item: $index'),
/// )
/// ```
class NKPopupMenu extends StatefulWidget {
  /// Optional text label displayed on the button.
  final String? buttonLabel;

  /// Optional icon displayed on the button (SF Symbol or custom image).
  final NKImageSource? buttonIcon;

  /// The list of menu items (and optional dividers) to display.
  final List<NKPopupMenuItem> items;

  /// Called when a menu item is selected with the index of the
  /// selected non-divider item.
  final ValueChanged<int>? onSelected;

  /// The tint color for the button.
  final Color? tintColor;

  /// The height of the button.
  final double height;

  /// Custom gesture recognizers for the platform view.
  ///
  /// By default, uses a [LongPressGestureRecognizer] which allows parent
  /// scrollables to still receive vertical drag gestures. The native UIButton
  /// uses `showsMenuAsPrimaryAction` so it only needs tap/long-press, not
  /// eager drag capture.
  ///
  /// Pass an empty set to let Flutter handle all gestures, or provide custom
  /// recognizers for specific use cases.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const NKPopupMenu({
    super.key,
    this.buttonLabel,
    this.buttonIcon,
    required this.items,
    this.onSelected,
    this.tintColor,
    this.height = 44.0,
    this.gestureRecognizers,
  });

  @override
  State<NKPopupMenu> createState() => _NKPopupMenuState();
}

class _NKPopupMenuState extends State<NKPopupMenu>
    with NKPlatformViewMixin<NKPopupMenu> {
  @override
  String get channelPrefix => 'native_kit/popup_menu';

  /// Default recognizers: LongPressGestureRecognizer allows parent scrollables
  /// to claim vertical drags while still forwarding taps to the native UIButton.
  static final Set<Factory<OneSequenceGestureRecognizer>>
      _defaultGestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(
      () => LongPressGestureRecognizer(),
    ),
  };

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onSelected' && call.arguments is int) {
      widget.onSelected?.call(call.arguments as int);
    }
  }

  @override
  void didUpdateWidget(NKPopupMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.buttonLabel != widget.buttonLabel ||
        oldWidget.buttonIcon != widget.buttonIcon ||
        oldWidget.tintColor != widget.tintColor ||
        !_itemsEqual(oldWidget.items, widget.items)) {
      _update();
    }
  }

  bool _itemsEqual(List<NKPopupMenuItem> a, List<NKPopupMenuItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final mapA = a[i].toMap();
      final mapB = b[i].toMap();
      if (mapA.length != mapB.length) return false;
      for (final key in mapA.keys) {
        if (mapA[key].toString() != mapB[key].toString()) return false;
      }
    }
    return true;
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('Failed to update NKPopupMenu: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      if (widget.buttonLabel != null) 'buttonLabel': widget.buttonLabel,
      if (widget.buttonIcon != null) 'buttonIcon': widget.buttonIcon!.toMap(),
      'items': widget.items.map((item) => item.toMap()).toList(),
      if (widget.tintColor != null) 'tintColor': widget.tintColor!.toARGB32(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NKPlatformBuilder(
        iosBuilder: (context) => UiKitView(
          viewType: 'native_kit/popup_menu_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers ?? _defaultGestureRecognizers,
        ),
        fallbackBuilder: (context) => _buildFallback(context),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showFallbackMenu(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.buttonIcon != null)
            Icon(
              CupertinoIcons.ellipsis_circle,
              color: widget.tintColor,
            ),
          if (widget.buttonLabel != null) ...[
            if (widget.buttonIcon != null) const SizedBox(width: 4),
            Text(
              widget.buttonLabel!,
              style: TextStyle(color: widget.tintColor),
            ),
          ],
        ],
      ),
    );
  }

  void _showFallbackMenu(BuildContext context) {
    final nonDividerItems = widget.items
        .where((item) => item is! NKPopupMenuDivider)
        .toList();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: nonDividerItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return CupertinoActionSheetAction(
            isDestructiveAction: item.isDestructive,
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSelected?.call(index);
            },
            child: Text(item.label),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
