import '../../models/nk_sf_symbol.dart';

/// Style of the slider track (iOS 26+).
enum NKSliderTrackStyle {
  /// Standard slider with draggable thumb.
  standard,

  /// Slider without a visible thumb knob.
  thumbless,
}

/// A tick mark on the slider track (iOS 26+).
class NKSliderTick {
  /// The position of the tick mark on the slider (between min and max).
  final double position;

  /// An optional label displayed at the tick mark.
  final String? title;

  /// An optional SF Symbol icon displayed at the tick mark.
  final NKSFSymbol? icon;

  const NKSliderTick({required this.position, this.title, this.icon});

  /// Converts this tick mark to a map for platform channel communication.
  Map<String, dynamic> toMap() => {
        'position': position,
        if (title != null) 'title': title,
        if (icon != null) 'icon': icon!.toMap(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKSliderTick &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          title == other.title &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(position, title, icon);
}
