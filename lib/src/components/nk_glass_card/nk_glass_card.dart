import 'package:flutter/cupertino.dart';

import '../../models/nk_glass_style.dart';
import '../nk_glass_container/nk_glass_container.dart';

/// A card widget that uses a Liquid Glass material background.
///
/// Composes [NKGlassContainer] with optional title and content layout.
/// When a [title] is provided, it is displayed above the [child] with
/// standard spacing.
///
/// Example:
/// ```dart
/// NKGlassCard(
///   title: 'Settings',
///   style: NKGlassStyle.regular,
///   child: Text('Card content here'),
/// )
/// ```
class NKGlassCard extends StatelessWidget {
  /// Optional title displayed above the [child].
  final String? title;

  /// Text style for the [title]. Defaults to the ambient
  /// [CupertinoThemeData.textTheme.navTitleTextStyle].
  final TextStyle? titleStyle;

  /// The glass effect style.
  final NKGlassStyle style;

  /// Optional tint color applied to the glass material.
  final Color? tintColor;

  /// Corner radius for the glass container.
  final double cornerRadius;

  /// Padding inside the glass container around the content.
  final EdgeInsetsGeometry padding;

  /// The widget to display as the card body.
  final Widget? child;

  /// Optional fixed width for the card.
  final double? width;

  const NKGlassCard({
    super.key,
    this.title,
    this.titleStyle,
    this.style = NKGlassStyle.regular,
    this.tintColor,
    this.cornerRadius = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return NKGlassContainer(
      style: style,
      tintColor: tintColor,
      cornerRadius: cornerRadius,
      padding: padding,
      width: width,
      child: _buildContent(context),
    );
  }

  Widget? _buildContent(BuildContext context) {
    if (title != null && child != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title!,
            style: titleStyle ??
                CupertinoTheme.of(context)
                    .textTheme
                    .navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          child!,
        ],
      );
    }

    if (title != null) {
      return Text(
        title!,
        style: titleStyle ??
            CupertinoTheme.of(context).textTheme.navTitleTextStyle,
      );
    }

    return child;
  }
}
