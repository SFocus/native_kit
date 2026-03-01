import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Mixin for StatefulWidget states that use per-view method channels.
///
/// Standardizes the pattern of creating a unique method channel per platform
/// view instance, preventing the shared-channel bug where only one view
/// receives updates.
mixin NKPlatformViewMixin<T extends StatefulWidget> on State<T> {
  MethodChannel? channel;
  int? viewId;

  /// Subclasses override this with their channel prefix.
  /// Example: 'native_kit/tab_bar' produces 'native_kit/tab_bar_$viewId'
  String get channelPrefix;

  /// Called when the platform view is created. Sets up the per-view channel.
  void onPlatformViewCreated(int id) {
    viewId = id;
    channel = MethodChannel('${channelPrefix}_$id');
    channel!.setMethodCallHandler(handleMethodCall);
    onViewReady();
  }

  /// Called after the channel is established. Override for initial sync.
  void onViewReady() {}

  /// Override to handle incoming method calls from native.
  Future<void> handleMethodCall(MethodCall call);

  @override
  void dispose() {
    channel?.setMethodCallHandler(null);
    super.dispose();
  }
}
