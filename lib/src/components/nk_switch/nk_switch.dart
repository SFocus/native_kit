import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// A native iOS-style toggle switch widget.
///
/// Uses UIKit's UISwitch on iOS for authentic native look and feel.
/// Falls back to CupertinoSwitch on other platforms.
///
/// Example:
/// ```dart
/// NKSwitch(
///   value: _isEnabled,
///   onChanged: (value) => setState(() => _isEnabled = value),
///   activeColor: Colors.green,
/// )
/// ```
class NKSwitch extends StatefulWidget {
  /// Whether the switch is on or off.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// The color of the switch when it is on.
  final Color? activeColor;

  /// The color of the switch track.
  final Color? trackColor;

  /// The color of the switch thumb.
  final Color? thumbColor;

  /// Whether the switch is enabled for user interaction.
  final bool enabled;

  const NKSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.enabled = true,
  });

  @override
  State<NKSwitch> createState() => _NKSwitchState();
}

class _NKSwitchState extends State<NKSwitch>
    with NKPlatformViewMixin<NKSwitch> {
  @override
  String get channelPrefix => 'native_kit/switch';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onValueChanged' && call.arguments is bool) {
      widget.onChanged?.call(call.arguments as bool);
    }
  }

  @override
  void didUpdateWidget(NKSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeColor != widget.activeColor ||
        oldWidget.trackColor != widget.trackColor ||
        oldWidget.thumbColor != widget.thumbColor) {
      _update();
      return;
    }

    if (oldWidget.value != widget.value) {
      _setValue(widget.value);
    }
    if (oldWidget.enabled != widget.enabled) {
      _setEnabled(widget.enabled);
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKSwitch: Failed to update: $e');
    }
  }

  Future<void> _setValue(bool value) async {
    try {
      await channel?.invokeMethod('setValue', {'value': value, 'animated': true});
    } catch (e) {
      debugPrint('Failed to update switch value: $e');
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    try {
      await channel?.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (e) {
      debugPrint('Failed to update switch enabled state: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'value': widget.value,
      'enabled': widget.enabled,
      if (widget.activeColor != null)
        'activeColor': widget.activeColor!.toARGB32(),
      if (widget.trackColor != null)
        'trackColor': widget.trackColor!.toARGB32(),
      if (widget.thumbColor != null)
        'thumbColor': widget.thumbColor!.toARGB32(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 51,
      height: 31,
      child: NKPlatformBuilder(
        iosBuilder: (context) => UiKitView(
          viewType: 'native_kit/switch_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (context) => CupertinoSwitch(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          activeTrackColor: widget.activeColor,
          inactiveTrackColor: widget.trackColor,
          thumbColor: widget.thumbColor,
        ),
      ),
    );
  }
}
