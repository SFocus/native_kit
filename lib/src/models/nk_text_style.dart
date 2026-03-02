import 'package:flutter/foundation.dart';

/// Font weight for native iOS components.
///
/// Maps directly to `UIFont.Weight` constants on iOS.
enum NKFontWeight {
  ultraLight,
  thin,
  light,
  regular,
  medium,
  semibold,
  bold,
  heavy,
  black,
}

/// Text style configuration for native iOS components.
///
/// Controls font family, size, and weight for UIKit views that support
/// text customization (buttons, tab bars, toolbars, segmented controls).
///
/// Custom fonts must be registered with [NKFontLoader] before use.
/// System fonts (SF Pro) work without registration.
///
/// ```dart
/// NKTextStyle(
///   fontFamily: 'Avenir',
///   fontSize: 16.0,
///   fontWeight: NKFontWeight.semibold,
/// )
/// ```
@immutable
class NKTextStyle {
  /// The font family name (e.g., 'Avenir', 'Georgia').
  ///
  /// Must be registered via [NKFontLoader] if not a system font.
  /// If null, the system default (SF Pro) is used.
  final String? fontFamily;

  /// The font size in points. If null, the component's default is used.
  final double? fontSize;

  /// The font weight. If null, the component's default is used.
  final NKFontWeight? fontWeight;

  const NKTextStyle({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
  });

  /// Serializes to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontSize != null) 'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight!.name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKTextStyle &&
          runtimeType == other.runtimeType &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight;

  @override
  int get hashCode => Object.hash(fontFamily, fontSize, fontWeight);
}
