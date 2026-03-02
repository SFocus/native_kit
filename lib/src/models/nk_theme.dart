import 'package:flutter/widgets.dart';

import 'nk_text_style.dart';

/// Global theme configuration for native_kit components.
///
/// Wrap your widget tree (or a subtree) with [NKTheme] to provide
/// default styling to all NK components underneath. Individual component
/// properties always override theme defaults.
///
/// ```dart
/// NKTheme(
///   data: NKThemeData(
///     textStyle: NKTextStyle(fontFamily: 'Avenir', fontSize: 15),
///     cornerRadius: 12.0,
///     tintColor: Colors.indigo,
///   ),
///   child: MaterialApp(...),
/// )
/// ```
class NKTheme extends InheritedWidget {
  /// The theme data applied to descendant NK components.
  final NKThemeData data;

  const NKTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the nearest [NKThemeData] from the widget tree.
  /// Returns null if no [NKTheme] ancestor exists.
  static NKThemeData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NKTheme>()?.data;
  }

  @override
  bool updateShouldNotify(NKTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for native_kit components.
///
/// All properties are optional. When set, they serve as defaults for
/// NK components that don't specify the property directly.
@immutable
class NKThemeData {
  /// Default text style applied to components that display text.
  final NKTextStyle? textStyle;

  /// Default corner radius applied to components that support it.
  final double? cornerRadius;

  /// Default tint color applied to components.
  final Color? tintColor;

  const NKThemeData({
    this.textStyle,
    this.cornerRadius,
    this.tintColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKThemeData &&
          runtimeType == other.runtimeType &&
          textStyle == other.textStyle &&
          cornerRadius == other.cornerRadius &&
          tintColor == other.tintColor;

  @override
  int get hashCode => Object.hash(textStyle, cornerRadius, tintColor);
}
