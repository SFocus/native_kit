import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/nk_image_source.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// Rendering mode for SF Symbols.
///
/// Controls how colors are applied to multi-layer SF Symbols.
/// Only applies when the [NKIcon.source] is an [NKSFSymbol].
/// Ignored for [NKImageData] sources.
enum NKSymbolRenderingMode {
  /// Single color applied to all layers.
  monochrome,

  /// Single color with varying opacity across layers.
  hierarchical,

  /// Multiple distinct colors applied to different layers.
  palette,

  /// System-defined multicolor rendering.
  multicolor,
}

/// A native iOS icon widget that displays SF Symbols or custom images.
///
/// Uses UIKit's UIImageView on iOS to render SF Symbols with full support
/// for rendering modes (monochrome, hierarchical, palette, multicolor).
/// Also supports custom raster images via [NKImageData].
/// Falls back to a basic Flutter Icon on other platforms.
///
/// Example:
/// ```dart
/// NKIcon(
///   source: NKSFSymbols.heart,
///   size: 32.0,
///   color: Colors.red,
/// )
///
/// // Palette rendering with multiple colors
/// NKIcon(
///   source: NKSFSymbol('cloud.sun.rain.fill'),
///   size: 48.0,
///   mode: NKSymbolRenderingMode.palette,
///   color: Colors.blue,
///   secondaryColor: Colors.yellow,
///   tertiaryColor: Colors.grey,
/// )
///
/// // Custom raster image
/// NKIcon(
///   source: NKImageData(pngBytes, scale: 3.0),
///   size: 32.0,
/// )
/// ```
class NKIcon extends StatefulWidget {
  /// The image source to display (SF Symbol or raster image).
  final NKImageSource source;

  /// The size of the icon in logical pixels.
  final double size;

  /// The primary color of the icon.
  final Color? color;

  /// The rendering mode for the SF Symbol.
  ///
  /// Only applies when [source] is an [NKSFSymbol]. Ignored for [NKImageData].
  final NKSymbolRenderingMode mode;

  /// The secondary color (used in palette rendering mode).
  final Color? secondaryColor;

  /// The tertiary color (used in palette rendering mode).
  final Color? tertiaryColor;

  const NKIcon({
    super.key,
    required this.source,
    this.size = 24.0,
    this.color,
    this.mode = NKSymbolRenderingMode.monochrome,
    this.secondaryColor,
    this.tertiaryColor,
  });

  @override
  State<NKIcon> createState() => _NKIconState();
}

class _NKIconState extends State<NKIcon> with NKPlatformViewMixin<NKIcon> {
  @override
  String get channelPrefix => 'native_kit/icon';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    // Display-only widget — no callbacks from native side.
  }

  @override
  void didUpdateWidget(NKIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.source != widget.source ||
        oldWidget.size != widget.size ||
        oldWidget.color != widget.color ||
        oldWidget.mode != widget.mode ||
        oldWidget.secondaryColor != widget.secondaryColor ||
        oldWidget.tertiaryColor != widget.tertiaryColor) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('Failed to update NKIcon: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'source': widget.source.toMap(),
      'size': widget.size,
      if (widget.color != null) 'color': widget.color!.toARGB32(),
      'mode': widget.mode.name,
      if (widget.secondaryColor != null)
        'secondaryColor': widget.secondaryColor!.toARGB32(),
      if (widget.tertiaryColor != null)
        'tertiaryColor': widget.tertiaryColor!.toARGB32(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: NKPlatformBuilder(
        iosBuilder: (context) => UiKitView(
          viewType: 'native_kit/icon_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        ),
        fallbackBuilder: (context) => Icon(
          const IconData(0),
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }
}
