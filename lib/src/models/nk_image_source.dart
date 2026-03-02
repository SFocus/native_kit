import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Color;
import 'package:flutter/services.dart' show rootBundle;

/// Controls how a custom image is rendered in native components.
///
/// - [template]: The image is treated as a mask and tinted by the component's
///   tint color. Best for monochrome icons (tab bars, buttons, menus).
/// - [original]: The image keeps its original colors. Best for full-color
///   images, logos, or photos.
enum NKImageRenderingMode {
  /// Image is tinted by the component's color (default).
  template,

  /// Image keeps its original colors.
  original,
}

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

  /// How the image should be rendered by native components.
  ///
  /// Defaults to [NKImageRenderingMode.template], which tints the image
  /// using the component's tint color (ideal for icons).
  /// Use [NKImageRenderingMode.original] to preserve the image's own colors.
  final NKImageRenderingMode renderingMode;

  /// Optional tint color applied to the image.
  ///
  /// When set, the image is rendered with this specific color regardless of the
  /// component's tint color. The image is always rendered as original (not
  /// template) when a tint color is provided, since the color is baked in.
  final Color? tintColor;

  const NKImageData(
    this.bytes, {
    this.scale = 1.0,
    this.renderingMode = NKImageRenderingMode.template,
    this.tintColor,
  });

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
    NKImageRenderingMode renderingMode = NKImageRenderingMode.template,
    Color? tintColor,
  }) async {
    final data = await rootBundle.load(assetPath);
    return NKImageData(
      data.buffer.asUint8List(),
      scale: devicePixelRatio,
      renderingMode: renderingMode,
      tintColor: tintColor,
    );
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
    NKImageRenderingMode renderingMode = NKImageRenderingMode.template,
    Color? tintColor,
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
      renderingMode: renderingMode,
      tintColor: tintColor,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'image_data',
        'data': bytes,
        'scale': scale,
        'renderingMode': renderingMode.name,
        if (tintColor != null) 'tintColor': tintColor!.toARGB32(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKImageData &&
          runtimeType == other.runtimeType &&
          listEquals(bytes, other.bytes) &&
          scale == other.scale &&
          renderingMode == other.renderingMode &&
          tintColor == other.tintColor;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(bytes), scale, renderingMode, tintColor);
}
