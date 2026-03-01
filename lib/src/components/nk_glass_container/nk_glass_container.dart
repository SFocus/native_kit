import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../models/nk_glass_style.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// A container that renders a native iOS 26 Liquid Glass material background
/// behind its [child] widget.
///
/// On iOS 26+, the glass material is a real `UIVisualEffectView` with
/// `UIGlassEffect`. On earlier iOS or non-iOS platforms, falls back to a
/// semi-transparent container.
///
/// Example:
/// ```dart
/// NKGlassContainer(
///   style: NKGlassStyle.regular,
///   cornerRadius: 20.0,
///   padding: EdgeInsets.all(16),
///   child: Text('Hello, Glass!'),
/// )
/// ```
class NKGlassContainer extends StatefulWidget {
  /// The glass effect style.
  final NKGlassStyle style;

  /// Whether the glass responds to touch with visual feedback.
  final bool isInteractive;

  /// Optional tint color applied to the glass material.
  final Color? tintColor;

  /// Corner radius. Ignored if [capsule] is true.
  final double? cornerRadius;

  /// If true, uses a capsule (pill) shape.
  final bool capsule;

  /// The widget to display on top of the glass background.
  final Widget? child;

  /// Padding inside the glass container around the [child].
  final EdgeInsetsGeometry padding;

  /// The width of the glass container.
  final double? width;

  /// The height of the glass container.
  final double? height;

  const NKGlassContainer({
    super.key,
    this.style = NKGlassStyle.regular,
    this.isInteractive = false,
    this.tintColor,
    this.cornerRadius = 20.0,
    this.capsule = false,
    this.child,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
  });

  @override
  State<NKGlassContainer> createState() => _NKGlassContainerState();
}

class _NKGlassContainerState extends State<NKGlassContainer>
    with NKPlatformViewMixin<NKGlassContainer> {
  @override
  String get channelPrefix => 'native_kit/glass_container';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    // Display-only — no callbacks from native side.
  }

  @override
  void didUpdateWidget(NKGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style ||
        oldWidget.isInteractive != widget.isInteractive ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.cornerRadius != widget.cornerRadius ||
        oldWidget.capsule != widget.capsule) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKGlassContainer: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'style': widget.style.name,
      'isInteractive': widget.isInteractive,
      if (widget.tintColor != null) 'tintColor': widget.tintColor!.toARGB32(),
      if (widget.cornerRadius != null) 'cornerRadius': widget.cornerRadius,
      'capsule': widget.capsule,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: NKPlatformBuilder(
        iosBuilder: (_) => Stack(
          children: [
            Positioned.fill(
              child: UiKitView(
                viewType: 'native_kit/glass_container_view',
                creationParams: _buildCreationParams(),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: onPlatformViewCreated,
                hitTestBehavior: PlatformViewHitTestBehavior.transparent,
              ),
            ),
            if (widget.child != null)
              Padding(
                padding: widget.padding,
                child: widget.child!,
              ),
          ],
        ),
        fallbackBuilder: (_) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    final radius = widget.capsule
        ? BorderRadius.circular(999)
        : BorderRadius.circular(widget.cornerRadius ?? 20.0);
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: (widget.tintColor ?? CupertinoColors.systemBackground)
              .withValues(alpha: 0.6),
          borderRadius: radius,
        ),
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}
