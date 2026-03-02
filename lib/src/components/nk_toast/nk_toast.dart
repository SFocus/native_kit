import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../models/nk_glass_style.dart';
import '../../models/nk_image_source.dart';
import '../nk_glass_container/nk_glass_container.dart';
import '../nk_icon/nk_icon.dart';

/// Position for the toast notification on screen.
enum NKToastPosition {
  /// Display the toast at the top of the screen.
  top,

  /// Display the toast at the bottom of the screen.
  bottom,
}

/// An imperative toast notification API with Liquid Glass styling.
///
/// Shows a brief message overlay that automatically dismisses after a
/// configurable duration. Uses [NKGlassContainer] with capsule shape
/// for the native iOS Liquid Glass appearance.
///
/// Example:
/// ```dart
/// NKToast.show(
///   context,
///   message: 'Item saved successfully',
///   icon: NKSFSymbols.checkmarkCircleFill,
///   position: NKToastPosition.top,
/// );
/// ```
///
/// The [show] method returns a [VoidCallback] that can be used to
/// dismiss the toast early:
/// ```dart
/// final dismiss = NKToast.show(context, message: 'Loading...');
/// // Later:
/// dismiss();
/// ```
class NKToast {
  NKToast._();

  /// Shows a toast notification with the given [message].
  ///
  /// Returns a [VoidCallback] that dismisses the toast when called.
  static VoidCallback show(
    BuildContext context, {
    required String message,
    NKImageSource? icon,
    NKGlassStyle style = NKGlassStyle.regular,
    Color? tintColor,
    Duration duration = const Duration(seconds: 3),
    NKToastPosition position = NKToastPosition.top,
    VoidCallback? onDismissed,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    var dismissed = false;

    void dismiss() {
      if (dismissed) return;
      dismissed = true;
      entry.remove();
      onDismissed?.call();
    }

    entry = OverlayEntry(
      builder: (context) => _NKToastOverlay(
        message: message,
        icon: icon,
        style: style,
        tintColor: tintColor,
        duration: duration,
        position: position,
        onDismissed: dismiss,
      ),
    );

    overlay.insert(entry);

    return () {
      if (!dismissed) {
        dismissed = true;
        entry.remove();
        onDismissed?.call();
      }
    };
  }
}

class _NKToastOverlay extends StatefulWidget {
  final String message;
  final NKImageSource? icon;
  final NKGlassStyle style;
  final Color? tintColor;
  final Duration duration;
  final NKToastPosition position;
  final VoidCallback onDismissed;

  const _NKToastOverlay({
    required this.message,
    this.icon,
    required this.style,
    this.tintColor,
    required this.duration,
    required this.position,
    required this.onDismissed,
  });

  @override
  State<_NKToastOverlay> createState() => _NKToastOverlayState();
}

class _NKToastOverlayState extends State<_NKToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final beginOffset = widget.position == NKToastPosition.top
        ? const Offset(0.0, -1.0)
        : const Offset(0.0, 1.0);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;

    _timer?.cancel();
    _timer = null;

    await _controller.reverse();

    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = widget.position == NKToastPosition.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    final edgePadding = widget.position == NKToastPosition.top
        ? const EdgeInsets.only(top: 8, left: 16, right: 16)
        : const EdgeInsets.only(bottom: 8, left: 16, right: 16);

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: edgePadding,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: NKGlassContainer(
                capsule: true,
                style: widget.style,
                tintColor: widget.tintColor,
                isInteractive: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      NKIcon(
                        source: widget.icon!,
                        size: 20,
                        color: widget.tintColor,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
