import 'package:flutter/foundation.dart';

/// SF Symbol icon representation shared across all NK components.
///
/// Use SF Symbol names like 'house', 'magnifyingglass', 'person', etc.
/// Browse all symbols at: https://developer.apple.com/sf-symbols/
@immutable
class NKSFSymbol {
  /// The SF Symbol name.
  final String name;

  /// Optional configuration for the symbol (weight, scale, etc).
  final NKSFSymbolConfig? config;

  const NKSFSymbol(
    this.name, {
    this.config,
  });

  /// Converts the symbol to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'type': 'sf_symbol',
      'name': name,
      if (config != null) 'config': config!.toMap(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKSFSymbol &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          config == other.config;

  @override
  int get hashCode => Object.hash(name, config);
}

/// Configuration for SF Symbol rendering.
@immutable
class NKSFSymbolConfig {
  /// Symbol weight (ultraLight, thin, light, regular, medium, semibold, bold, heavy, black).
  final String? weight;

  /// Symbol scale (small, medium, large).
  final String? scale;

  const NKSFSymbolConfig({
    this.weight,
    this.scale,
  });

  Map<String, dynamic> toMap() {
    return {
      if (weight != null) 'weight': weight,
      if (scale != null) 'scale': scale,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKSFSymbolConfig &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          scale == other.scale;

  @override
  int get hashCode => Object.hash(weight, scale);
}

/// Common SF Symbols for quick access.
class NKSFSymbols {
  const NKSFSymbols._();

  // Navigation
  static const house = NKSFSymbol('house');
  static const houseFill = NKSFSymbol('house.fill');
  static const magnifyingglass = NKSFSymbol('magnifyingglass');
  static const person = NKSFSymbol('person');
  static const personFill = NKSFSymbol('person.fill');
  static const gear = NKSFSymbol('gear');
  static const gearFill = NKSFSymbol('gear.fill');

  // Actions
  static const heart = NKSFSymbol('heart');
  static const heartFill = NKSFSymbol('heart.fill');
  static const star = NKSFSymbol('star');
  static const starFill = NKSFSymbol('star.fill');
  static const bookmark = NKSFSymbol('bookmark');
  static const bookmarkFill = NKSFSymbol('bookmark.fill');

  // Communication
  static const bell = NKSFSymbol('bell');
  static const bellFill = NKSFSymbol('bell.fill');
  static const envelope = NKSFSymbol('envelope');
  static const envelopeFill = NKSFSymbol('envelope.fill');
  static const message = NKSFSymbol('message');
  static const messageFill = NKSFSymbol('message.fill');

  // Media
  static const play = NKSFSymbol('play');
  static const playFill = NKSFSymbol('play.fill');
  static const pause = NKSFSymbol('pause');
  static const pauseFill = NKSFSymbol('pause.fill');
  static const photo = NKSFSymbol('photo');
  static const photoFill = NKSFSymbol('photo.fill');

  // Shopping
  static const cart = NKSFSymbol('cart');
  static const cartFill = NKSFSymbol('cart.fill');
  static const bag = NKSFSymbol('bag');
  static const bagFill = NKSFSymbol('bag.fill');

  // Location
  static const location = NKSFSymbol('location');
  static const locationFill = NKSFSymbol('location.fill');
  static const map = NKSFSymbol('map');
  static const mapFill = NKSFSymbol('map.fill');

  // Plus/Minus
  static const plus = NKSFSymbol('plus');
  static const plusCircle = NKSFSymbol('plus.circle');
  static const plusCircleFill = NKSFSymbol('plus.circle.fill');
  static const minus = NKSFSymbol('minus');
  static const minusCircle = NKSFSymbol('minus.circle');
  static const minusCircleFill = NKSFSymbol('minus.circle.fill');
}
