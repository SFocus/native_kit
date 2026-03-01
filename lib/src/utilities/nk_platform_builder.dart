import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';

/// Builds native platform views on iOS, fallback widgets elsewhere.
///
/// On iOS, renders the real native UIKit component via platform views.
/// On other platforms, renders a fallback Flutter widget (typically a
/// Cupertino equivalent).
class NKPlatformBuilder extends StatelessWidget {
  final Widget Function(BuildContext) iosBuilder;
  final Widget Function(BuildContext) fallbackBuilder;

  const NKPlatformBuilder({
    super.key,
    required this.iosBuilder,
    required this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iosBuilder(context);
    }
    return fallbackBuilder(context);
  }
}
