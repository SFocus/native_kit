import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_kit/native_kit.dart';

void main() {
  group('NKImageSource hierarchy', () {
    test('NKSFSymbol is an NKImageSource', () {
      const symbol = NKSFSymbol('star.fill');
      expect(symbol, isA<NKImageSource>());
    });

    test('NKImageData is an NKImageSource', () {
      final data = NKImageData(Uint8List.fromList([0, 1, 2, 3]));
      expect(data, isA<NKImageSource>());
    });

    test('NKSFSymbols constants are NKImageSource', () {
      const NKImageSource source = NKSFSymbols.star;
      expect(source, isA<NKSFSymbol>());
    });
  });

  group('NKSFSymbol.toMap()', () {
    test('produces type sf_symbol with name', () {
      const symbol = NKSFSymbol('star.fill');
      final map = symbol.toMap();

      expect(map['type'], 'sf_symbol');
      expect(map['name'], 'star.fill');
    });

    test('includes config when provided', () {
      const symbol = NKSFSymbol(
        'star.fill',
        config: NKSFSymbolConfig(
          weight: 'bold',
          scale: 'large',
        ),
      );
      final map = symbol.toMap();

      expect(map['type'], 'sf_symbol');
      expect(map['name'], 'star.fill');
      expect(map['config'], isA<Map<String, dynamic>>());
      expect(map['config']['weight'], 'bold');
      expect(map['config']['scale'], 'large');
    });

    test('omits config key when config is null', () {
      const symbol = NKSFSymbol('star.fill');
      final map = symbol.toMap();

      expect(map.containsKey('config'), isFalse);
    });
  });

  group('NKImageData', () {
    test('toMap() produces type image_data with bytes and scale', () {
      final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      final imageData = NKImageData(bytes, scale: 2.0);
      final map = imageData.toMap();

      expect(map['type'], 'image_data');
      expect(map['data'], bytes);
      expect(map['scale'], 2.0);
    });

    test('default scale is 1.0', () {
      final imageData = NKImageData(Uint8List.fromList([1, 2, 3]));
      expect(imageData.scale, 1.0);

      final map = imageData.toMap();
      expect(map['scale'], 1.0);
    });

    test('equality based on bytes length and scale', () {
      final a = NKImageData(Uint8List.fromList([1, 2, 3]), scale: 2.0);
      final b = NKImageData(Uint8List.fromList([4, 5, 6]), scale: 2.0);
      final c = NKImageData(Uint8List.fromList([1, 2, 3, 4]), scale: 2.0);
      final d = NKImageData(Uint8List.fromList([1, 2, 3]), scale: 3.0);

      // Same length and scale → equal
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      // Different length → not equal
      expect(a, isNot(equals(c)));

      // Different scale → not equal
      expect(a, isNot(equals(d)));
    });
  });

  group('Component toMap() with NKImageSource', () {
    test('NKPopupMenuItem accepts NKSFSymbol icon', () {
      const item = NKPopupMenuItem(
        label: 'Copy',
        icon: NKSFSymbols.star,
      );
      final map = item.toMap();

      expect(map['label'], 'Copy');
      expect(map['icon'], isA<Map<String, dynamic>>());
      expect(map['icon']['type'], 'sf_symbol');
    });

    test('NKPopupMenuItem accepts NKImageData icon', () {
      final item = NKPopupMenuItem(
        label: 'Custom',
        icon: NKImageData(Uint8List.fromList([1, 2, 3])),
      );
      final map = item.toMap();

      expect(map['label'], 'Custom');
      expect(map['icon'], isA<Map<String, dynamic>>());
      expect(map['icon']['type'], 'image_data');
    });

    test('NKPopupMenuDivider toMap unchanged', () {
      const divider = NKPopupMenuDivider();
      final map = divider.toMap();

      expect(map['isDivider'], true);
      expect(map.containsKey('icon'), isFalse);
    });
  });
}
