import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/nk_sf_symbol.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// A single button within an [NKGlassButtonGroup].
@immutable
class NKGlassButton {
  /// The text label displayed on the button.
  final String? label;

  /// An optional SF Symbol icon displayed on the button.
  final NKSFSymbol? icon;

  /// Callback invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// The tint color applied to the button.
  final Color? tintColor;

  const NKGlassButton({
    this.label,
    this.icon,
    this.onPressed,
    this.tintColor,
  });

  /// Converts the button to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      if (label != null) 'label': label,
      if (icon != null) 'icon': icon!.toMap(),
      if (tintColor != null) 'tintColor': tintColor!.toARGB32(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKGlassButton &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          icon == other.icon &&
          tintColor == other.tintColor;

  @override
  int get hashCode => Object.hash(label, icon, tintColor);
}

/// A group of native iOS Liquid Glass buttons displayed in a horizontal row.
///
/// Uses a `UIGlassContainerEffect` on iOS 26+ for an authentic grouped glass
/// look. Falls back to a row of [CupertinoButton] widgets on other platforms.
///
/// Example:
/// ```dart
/// NKGlassButtonGroup(
///   buttons: [
///     NKGlassButton(
///       label: 'Share',
///       icon: NKSFSymbols.play,
///       onPressed: () => print('Share'),
///     ),
///     NKGlassButton(
///       label: 'Save',
///       icon: NKSFSymbols.bookmark,
///       onPressed: () => print('Save'),
///     ),
///   ],
/// )
/// ```
class NKGlassButtonGroup extends StatefulWidget {
  /// The list of buttons to display in the group.
  final List<NKGlassButton> buttons;

  /// The spacing between buttons within the glass container.
  final double spacing;

  /// The height of the button group.
  final double height;

  const NKGlassButtonGroup({
    super.key,
    required this.buttons,
    this.spacing = 12.0,
    this.height = 44.0,
  });

  @override
  State<NKGlassButtonGroup> createState() => _NKGlassButtonGroupState();
}

class _NKGlassButtonGroupState extends State<NKGlassButtonGroup>
    with NKPlatformViewMixin<NKGlassButtonGroup> {
  @override
  String get channelPrefix => 'native_kit/glass_button_group';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onButtonPressed') {
      final int index = call.arguments as int;
      if (index >= 0 && index < widget.buttons.length) {
        widget.buttons[index].onPressed?.call();
      }
    }
  }

  @override
  void didUpdateWidget(NKGlassButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.buttons, widget.buttons)) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKGlassButtonGroup: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'buttons': widget.buttons.map((b) => b.toMap()).toList(),
      'spacing': widget.spacing,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NKPlatformBuilder(
        iosBuilder: (_) => UiKitView(
          viewType: 'native_kit/glass_button_group_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (_) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: widget.spacing,
          children: [
            for (int i = 0; i < widget.buttons.length; i++)
              CupertinoButton(
                onPressed: widget.buttons[i].onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.buttons[i].icon != null)
                      Icon(
                        CupertinoIcons.circle,
                        color: widget.buttons[i].tintColor,
                      ),
                    if (widget.buttons[i].icon != null &&
                        widget.buttons[i].label != null)
                      const SizedBox(width: 6),
                    if (widget.buttons[i].label != null)
                      Text(
                        widget.buttons[i].label!,
                        style: TextStyle(color: widget.buttons[i].tintColor),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
