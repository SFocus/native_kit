import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_kit/native_kit.dart';

/// Cache to avoid re-rendering the same SVG on repeated visits.
final _svgCache = <String, NKImageData>{};

/// Converts an SVG asset file to [NKImageData] for use in NK components.
///
/// Results are cached by a key derived from [assetPath], [size], and
/// [devicePixelRatio], so repeated calls return instantly.
Future<NKImageData> svgAssetToImageData(
  String assetPath, {
  double size = 24.0,
  double devicePixelRatio = 1.0,
}) async {
  final cacheKey = '$assetPath@${size}x$devicePixelRatio';
  final cached = _svgCache[cacheKey];
  if (cached != null) return cached;

  final pictureInfo = await vg.loadPicture(
    SvgAssetLoader(assetPath),
    null,
  );
  try {
    final data = await NKImageData.fromPicture(
      pictureInfo.picture,
      size: ui.Size(size, size),
      devicePixelRatio: devicePixelRatio,
    );
    _svgCache[cacheKey] = data;
    return data;
  } finally {
    pictureInfo.picture.dispose();
  }
}

/// Loads multiple SVG asset icons in parallel.
///
/// Cached icons are returned immediately; only uncached ones are rendered.
Future<Map<String, NKImageData>> loadSvgAssetIcons(
  Map<String, String> assetMap, {
  double size = 24.0,
  double devicePixelRatio = 1.0,
}) async {
  final entries = await Future.wait(
    assetMap.entries.map((e) async {
      final data = await svgAssetToImageData(
        e.value,
        size: size,
        devicePixelRatio: devicePixelRatio,
      );
      return MapEntry(e.key, data);
    }),
  );
  return Map.fromEntries(entries);
}
