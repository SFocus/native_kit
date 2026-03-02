import 'package:flutter/services.dart';

/// Registers Flutter asset fonts with the native iOS font system at runtime.
///
/// Fonts declared in `pubspec.yaml` are bundled as Flutter assets but are
/// NOT automatically available to native UIKit views. Call [registerFont]
/// or [registerFontFromPackage] before using a custom font family in
/// [NKTextStyle].
///
/// ```dart
/// // In main(), before runApp():
/// await NKFontLoader.registerFont('assets/fonts/Avenir-Regular.ttf');
/// await NKFontLoader.registerFont('assets/fonts/Avenir-Bold.ttf');
///
/// // From a package dependency:
/// await NKFontLoader.registerFontFromPackage(
///   'fonts/CustomFont.ttf',
///   package: 'my_font_package',
/// );
/// ```
class NKFontLoader {
  static const _channel = MethodChannel('native_kit');

  NKFontLoader._();

  /// Registers a font from the app's own assets.
  ///
  /// [assetPath] is the path as declared in `pubspec.yaml`
  /// (e.g., `'assets/fonts/MyFont-Regular.ttf'`).
  ///
  /// Returns `true` if the font was registered successfully.
  static Future<bool> registerFont(String assetPath) async {
    final result = await _channel.invokeMethod<bool>(
      'registerFont',
      {'assetPath': assetPath},
    );
    return result ?? false;
  }

  /// Registers a font from a Flutter package dependency.
  ///
  /// [assetPath] is the path within the package (e.g., `'fonts/MyFont.ttf'`).
  /// [package] is the package name (e.g., `'my_font_package'`).
  static Future<bool> registerFontFromPackage(
    String assetPath, {
    required String package,
  }) async {
    final result = await _channel.invokeMethod<bool>(
      'registerFont',
      {'assetPath': assetPath, 'package': package},
    );
    return result ?? false;
  }

  /// Registers multiple fonts from the app's own assets.
  static Future<void> registerFonts(List<String> assetPaths) async {
    for (final path in assetPaths) {
      await registerFont(path);
    }
  }
}
