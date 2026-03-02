import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/nk_image_source.dart';
import '../../models/nk_text_style.dart';
import '../../models/nk_theme.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// The visual style of an [NKButton].
///
/// Maps directly to UIButton.Configuration styles on iOS.
enum NKButtonStyle {
  /// A button with no background or border.
  plain,

  /// A button with a gray background.
  gray,

  /// A button with a tinted background matching the tint color.
  tinted,

  /// A button with a rounded border.
  bordered,

  /// A button with a prominent rounded border (filled with tint color).
  borderedProminent,

  /// A button with a filled background.
  filled,

  /// A button with a translucent Liquid Glass style (iOS 26+).
  /// Falls back to [bordered] on earlier iOS versions.
  glass,

  /// A button with a clear Liquid Glass style (iOS 26+).
  /// Falls back to [plain] on earlier iOS versions.
  clearGlass,

  /// A button with a prominent Liquid Glass style tinted with the app's
  /// tint color (iOS 26+). Falls back to [borderedProminent] on earlier iOS.
  prominentGlass,

  /// A button with a prominent, clear Liquid Glass style (iOS 26+).
  /// Falls back to [filled] on earlier iOS versions.
  prominentClearGlass,
}

/// A native iOS-style button widget.
///
/// Uses UIKit's UIButton with UIButton.Configuration API on iOS for authentic
/// native look and feel. Falls back to [CupertinoButton] on other platforms.
///
/// Example:
/// ```dart
/// NKButton(
///   label: 'Sign In',
///   icon: NKSFSymbols.person,
///   style: NKButtonStyle.filled,
///   tintColor: Colors.blue,
///   onPressed: () => print('Pressed!'),
/// )
/// ```
///
/// For icon-only buttons, use the convenience constructor:
/// ```dart
/// NKButton.icon(
///   icon: NKSFSymbols.heartFill,
///   style: NKButtonStyle.plain,
///   onPressed: () => print('Liked!'),
/// )
/// ```
class NKButton extends StatefulWidget {
  /// The text label displayed on the button.
  final String? label;

  /// An optional icon displayed alongside the label (SF Symbol or custom image).
  final NKImageSource? icon;

  /// The visual style of the button.
  final NKButtonStyle style;

  /// Callback invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// The tint color applied to the button.
  final Color? tintColor;

  /// Whether the button is enabled.
  final bool enabled;

  /// The height of the button.
  final double height;

  /// Text style for the button label (font family, size, weight).
  final NKTextStyle? textStyle;

  /// Corner radius of the button background.
  final double? cornerRadius;

  const NKButton({
    super.key,
    this.label,
    this.icon,
    this.style = NKButtonStyle.filled,
    this.onPressed,
    this.tintColor,
    this.enabled = true,
    this.height = 44.0,
    this.textStyle,
    this.cornerRadius,
  });

  /// Creates an icon-only button with no label.
  const NKButton.icon({
    super.key,
    required NKImageSource this.icon,
    this.style = NKButtonStyle.filled,
    this.onPressed,
    this.tintColor,
    this.enabled = true,
    this.height = 44.0,
    this.textStyle,
    this.cornerRadius,
  }) : label = null;

  @override
  State<NKButton> createState() => _NKButtonState();
}

class _NKButtonState extends State<NKButton>
    with NKPlatformViewMixin<NKButton> {
  @override
  String get channelPrefix => 'native_kit/button';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onPressed') {
      widget.onPressed?.call();
    }
  }

  @override
  void didUpdateWidget(NKButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled != widget.enabled ||
        oldWidget.label != widget.label ||
        oldWidget.icon != widget.icon ||
        oldWidget.style != widget.style ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.height != widget.height ||
        oldWidget.textStyle != widget.textStyle ||
        oldWidget.cornerRadius != widget.cornerRadius) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      final theme = context.mounted ? NKTheme.of(context) : null;
      await channel?.invokeMethod('update', _buildCreationParams(theme));
    } catch (e) {
      debugPrint('NKButton: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams(NKThemeData? theme) {
    final effectiveTextStyle = widget.textStyle ?? theme?.textStyle;
    final effectiveCornerRadius = widget.cornerRadius ?? theme?.cornerRadius;
    final effectiveTintColor = widget.tintColor ?? theme?.tintColor;

    return {
      if (widget.label != null) 'label': widget.label,
      if (widget.icon != null) 'icon': widget.icon!.toMap(),
      'style': widget.style.name,
      'enabled': widget.enabled,
      if (effectiveTintColor != null)
        'tintColor': effectiveTintColor.toARGB32(),
      'height': widget.height,
      if (effectiveTextStyle != null) 'textStyle': effectiveTextStyle.toMap(),
      if (effectiveCornerRadius != null) 'cornerRadius': effectiveCornerRadius,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = NKTheme.of(context);
    final isIconOnly = widget.label == null && widget.icon != null;
    return SizedBox(
      height: widget.height,
      width: isIconOnly ? widget.height : null,
      child: NKPlatformBuilder(
        iosBuilder: (_) => UiKitView(
          viewType: 'native_kit/button_view',
          creationParams: _buildCreationParams(theme),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (_) => CupertinoButton(
          onPressed: widget.enabled ? widget.onPressed : null,
          color: widget.style == NKButtonStyle.filled ||
                  widget.style == NKButtonStyle.borderedProminent ||
                  widget.style == NKButtonStyle.prominentGlass ||
                  widget.style == NKButtonStyle.prominentClearGlass
              ? (widget.tintColor ?? CupertinoColors.activeBlue)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(
                  CupertinoIcons.circle,
                  color: widget.tintColor,
                ),
              if (widget.icon != null && widget.label != null)
                const SizedBox(width: 6),
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(color: widget.tintColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
