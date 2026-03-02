import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

/// Base type for all image sources that can be passed to NK components.
///
/// Use [NKSFSymbol] for SF Symbol icons, or [NKImageData] for pre-rendered
/// raster images (e.g., from SVG or asset files).
abstract class NKImageSource {
  const NKImageSource();

  /// Serializes this image source for the platform method channel.
  Map<String, dynamic> toMap();
}

/// Pre-rendered raster image data (PNG bytes) for native components.
///
/// Use this to display custom images (SVGs, PNGs, etc.) in any NK component
/// that accepts an [NKImageSource].
///
/// The [bytes] must contain valid PNG-encoded image data. The [scale] parameter
/// controls the device pixel ratio (default 1.0).
///
/// Example with flutter_svg:
/// ```dart
/// import 'package:flutter_svg/flutter_svg.dart';
///
/// final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
/// final imageData = await NKImageData.fromPicture(
///   pictureInfo.picture,
///   size: pictureInfo.size,
///   devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
/// );
/// pictureInfo.picture.dispose();
/// ```
class NKImageData extends NKImageSource {
  /// PNG-encoded image bytes.
  final Uint8List bytes;

  /// Device pixel ratio scale factor. Defaults to 1.0.
  ///
  /// Set to 2.0 or 3.0 to match the device screen density when the [bytes]
  /// were rendered at that density.
  final double scale;

  const NKImageData(this.bytes, {this.scale = 1.0});

  /// Loads a PNG/image asset directly into [NKImageData].
  ///
  /// This is the most efficient path for pre-rendered images — no SVG parsing
  /// or rasterization needed. Just reads raw bytes from the asset bundle.
  ///
  /// ```dart
  /// final icon = await NKImageData.fromAsset('assets/icons/logo.png');
  /// NKButton(icon: icon, label: 'Go', onPressed: () {});
  /// ```
  static Future<NKImageData> fromAsset(
    String assetPath, {
    double devicePixelRatio = 1.0,
  }) async {
    final data = await rootBundle.load(assetPath);
    return NKImageData(data.buffer.asUint8List(), scale: devicePixelRatio);
  }

  /// Renders a [ui.Picture] to PNG bytes and wraps it in [NKImageData].
  ///
  /// [picture] - The picture to render (e.g., from flutter_svg).
  /// [size] - The logical size of the picture.
  /// [devicePixelRatio] - The device pixel ratio for rendering. Defaults to
  ///   1.0. Pass the actual device pixel ratio for crisp rendering on retina
  ///   displays.
  static Future<NKImageData> fromPicture(
    ui.Picture picture, {
    required ui.Size size,
    double devicePixelRatio = 1.0,
  }) async {
    final int width = (size.width * devicePixelRatio).ceil();
    final int height = (size.height * devicePixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.scale(devicePixelRatio);
    canvas.drawPicture(picture);
    final scaledPicture = recorder.endRecording();

    final image = await scaledPicture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    scaledPicture.dispose();

    if (byteData == null) {
      throw StateError('Failed to encode image to PNG bytes');
    }

    return NKImageData(
      byteData.buffer.asUint8List(),
      scale: devicePixelRatio,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'image_data',
        'data': bytes,
        'scale': scale,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKImageData &&
          runtimeType == other.runtimeType &&
          bytes.length == other.bytes.length &&
          scale == other.scale;

  @override
  int get hashCode => Object.hash(bytes.length, scale);
}
