import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// The visual style of the progress indicator.
enum NKProgressViewStyle {
  /// A horizontal progress bar (UIProgressView).
  bar,

  /// A spinning activity indicator (UIActivityIndicatorView).
  spinner,
}

/// The size of the spinner when using [NKProgressViewStyle.spinner].
enum NKSpinnerSize {
  /// Small spinner (20pt).
  small,

  /// Medium spinner (default, 37pt).
  medium,

  /// Large spinner (70pt).
  large,
}

/// A native iOS progress indicator.
///
/// Renders a `UIProgressView` (bar) or `UIActivityIndicatorView` (spinner)
/// on iOS 18+. On iOS 26+, both variants get Liquid Glass styling
/// automatically.
///
/// Falls back to [CupertinoActivityIndicator] or a simple progress bar
/// on other platforms.
///
/// Example (determinate bar):
/// ```dart
/// NKProgressView(
///   style: NKProgressViewStyle.bar,
///   value: 0.65,
///   tintColor: Colors.blue,
/// )
/// ```
///
/// Example (spinner):
/// ```dart
/// NKProgressView(
///   style: NKProgressViewStyle.spinner,
///   spinnerSize: NKSpinnerSize.large,
/// )
/// ```
class NKProgressView extends StatefulWidget {
  /// The visual style: bar or spinner.
  final NKProgressViewStyle style;

  /// Progress value from 0.0 to 1.0 (bar only).
  /// If null, the bar shows an indeterminate animation.
  final double? value;

  /// Tint color for the progress bar or spinner.
  final Color? tintColor;

  /// Track color behind the progress bar (bar only).
  final Color? trackColor;

  /// Size of the spinner (spinner only).
  final NKSpinnerSize spinnerSize;

  const NKProgressView({
    super.key,
    this.style = NKProgressViewStyle.bar,
    this.value,
    this.tintColor,
    this.trackColor,
    this.spinnerSize = NKSpinnerSize.medium,
  });

  @override
  State<NKProgressView> createState() => _NKProgressViewState();
}

class _NKProgressViewState extends State<NKProgressView>
    with NKPlatformViewMixin<NKProgressView> {
  @override
  String get channelPrefix => 'native_kit/progress';

  @override
  Future<void> handleMethodCall(MethodCall call) async {}

  @override
  void didUpdateWidget(NKProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style ||
        oldWidget.value != widget.value ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.trackColor != widget.trackColor ||
        oldWidget.spinnerSize != widget.spinnerSize) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKProgressView: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'style': widget.style.name,
      if (widget.value != null) 'value': widget.value,
      if (widget.tintColor != null) 'tintColor': widget.tintColor!.toARGB32(),
      if (widget.trackColor != null)
        'trackColor': widget.trackColor!.toARGB32(),
      'spinnerSize': widget.spinnerSize.name,
    };
  }

  double get _height {
    if (widget.style == NKProgressViewStyle.bar) return 4.0;
    switch (widget.spinnerSize) {
      case NKSpinnerSize.small:
        return 20.0;
      case NKSpinnerSize.medium:
        return 37.0;
      case NKSpinnerSize.large:
        return 70.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpinner = widget.style == NKProgressViewStyle.spinner;
    final size = _height;

    Widget child = NKPlatformBuilder(
      iosBuilder: (_) => UiKitView(
        viewType: 'native_kit/progress_view',
        creationParams: _buildCreationParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      ),
      fallbackBuilder: (_) => _buildFallback(),
    );

    // Spinner needs both width and height constrained.
    // Bar stretches to full width (height-only constraint is fine
    // when a parent provides finite width).
    if (isSpinner) {
      return SizedBox(width: size, height: size, child: child);
    }
    return SizedBox(height: size, child: child);
  }

  Widget _buildFallback() {
    if (widget.style == NKProgressViewStyle.spinner) {
      return CupertinoActivityIndicator(
        radius: _height / 2,
        color: widget.tintColor,
      );
    }
    // Bar fallback
    final progress = (widget.value ?? 0.0).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          Container(
            height: 4,
            color: widget.trackColor ??
                CupertinoColors.systemFill.resolveFrom(context),
          ),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 4,
              color: widget.tintColor ?? CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }
}
