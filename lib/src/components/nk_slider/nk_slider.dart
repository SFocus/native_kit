import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';
import 'nk_slider_tick.dart';

export 'nk_slider_tick.dart';

/// A native iOS-style slider widget.
///
/// Uses UIKit's UISlider on iOS for authentic native look and feel.
/// Falls back to CupertinoSlider on other platforms.
///
/// Example:
/// ```dart
/// NKSlider(
///   value: _volume,
///   min: 0.0,
///   max: 100.0,
///   onChanged: (value) => setState(() => _volume = value),
///   activeColor: Colors.blue,
/// )
/// ```
class NKSlider extends StatefulWidget {
  /// The current value of the slider.
  final double value;

  /// Called continuously as the user drags the slider.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts dragging the slider.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user stops dragging the slider.
  final ValueChanged<double>? onChangeEnd;

  /// The minimum value of the slider.
  final double min;

  /// The maximum value of the slider.
  final double max;

  /// If non-null, the slider will snap to discrete values at this interval.
  final double? step;

  /// The color of the active portion of the track (left of thumb).
  final Color? activeColor;

  /// The color of the inactive portion of the track (right of thumb).
  final Color? inactiveColor;

  /// The color of the slider thumb.
  final Color? thumbColor;

  /// Whether the slider is enabled for user interaction.
  final bool enabled;

  /// The height of the slider widget.
  final double height;

  /// Track style (standard or thumbless). iOS 26+ only, ignored on earlier versions.
  final NKSliderTrackStyle trackStyle;

  /// Tick marks on the track. iOS 26+ only.
  final List<NKSliderTick>? ticks;

  /// Number of evenly-spaced ticks. Alternative to [ticks]. iOS 26+ only.
  final int? numberOfTicks;

  /// If true, the slider only allows values at tick positions. iOS 26+ only.
  final bool allowsTickValuesOnly;

  /// A neutral/anchor value on the track fill. iOS 26+ only.
  final double? neutralValue;

  /// Restricts the draggable range. Tuple of (min, max). iOS 26+ only.
  final (double, double)? enabledRange;

  const NKSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.step,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.enabled = true,
    this.height = 44.0,
    this.trackStyle = NKSliderTrackStyle.standard,
    this.ticks,
    this.numberOfTicks,
    this.allowsTickValuesOnly = false,
    this.neutralValue,
    this.enabledRange,
  });

  @override
  State<NKSlider> createState() => _NKSliderState();
}

class _NKSliderState extends State<NKSlider>
    with NKPlatformViewMixin<NKSlider> {
  @override
  String get channelPrefix => 'native_kit/slider';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onValueChanged':
        if (call.arguments is double) {
          widget.onChanged?.call(call.arguments as double);
        }
      case 'onChangeStart':
        if (call.arguments is double) {
          widget.onChangeStart?.call(call.arguments as double);
        }
      case 'onChangeEnd':
        if (call.arguments is double) {
          widget.onChangeEnd?.call(call.arguments as double);
        }
    }
  }

  @override
  void didUpdateWidget(NKSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activeColor != widget.activeColor ||
        oldWidget.inactiveColor != widget.inactiveColor ||
        oldWidget.thumbColor != widget.thumbColor ||
        oldWidget.step != widget.step) {
      _update();
      return;
    }

    if (oldWidget.value != widget.value) {
      _setValue(widget.value);
    }
    if (oldWidget.enabled != widget.enabled) {
      _setEnabled(widget.enabled);
    }
    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      _setRange(widget.min, widget.max);
    }
    if (oldWidget.trackStyle != widget.trackStyle ||
        !listEquals(oldWidget.ticks, widget.ticks) ||
        oldWidget.numberOfTicks != widget.numberOfTicks ||
        oldWidget.allowsTickValuesOnly != widget.allowsTickValuesOnly ||
        oldWidget.neutralValue != widget.neutralValue ||
        oldWidget.enabledRange != widget.enabledRange) {
      _setTrackConfiguration();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKSlider: Failed to update: $e');
    }
  }

  Future<void> _setValue(double value) async {
    try {
      await channel
          ?.invokeMethod('setValue', {'value': value, 'animated': true});
    } catch (e) {
      debugPrint('Failed to update slider value: $e');
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    try {
      await channel?.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (e) {
      debugPrint('Failed to update slider enabled state: $e');
    }
  }

  Future<void> _setRange(double min, double max) async {
    try {
      await channel?.invokeMethod('setRange', {'min': min, 'max': max});
    } catch (e) {
      debugPrint('Failed to update slider range: $e');
    }
  }

  Future<void> _setTrackConfiguration() async {
    try {
      await channel?.invokeMethod('setTrackConfiguration', {
        'trackStyle': widget.trackStyle.name,
        if (widget.ticks != null)
          'ticks': widget.ticks!.map((t) => t.toMap()).toList(),
        if (widget.numberOfTicks != null) 'numberOfTicks': widget.numberOfTicks,
        'allowsTickValuesOnly': widget.allowsTickValuesOnly,
        if (widget.neutralValue != null) 'neutralValue': widget.neutralValue,
        if (widget.enabledRange != null) ...{
          'enabledRangeMin': widget.enabledRange!.$1,
          'enabledRangeMax': widget.enabledRange!.$2,
        },
      });
    } catch (e) {
      debugPrint('Failed to update slider track configuration: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'enabled': widget.enabled,
      if (widget.step != null) 'step': widget.step,
      if (widget.activeColor != null)
        'activeColor': widget.activeColor!.toARGB32(),
      if (widget.inactiveColor != null)
        'inactiveColor': widget.inactiveColor!.toARGB32(),
      if (widget.thumbColor != null)
        'thumbColor': widget.thumbColor!.toARGB32(),
      'trackStyle': widget.trackStyle.name,
      if (widget.ticks != null)
        'ticks': widget.ticks!.map((t) => t.toMap()).toList(),
      if (widget.numberOfTicks != null) 'numberOfTicks': widget.numberOfTicks,
      'allowsTickValuesOnly': widget.allowsTickValuesOnly,
      if (widget.neutralValue != null) 'neutralValue': widget.neutralValue,
      if (widget.enabledRange != null) ...{
        'enabledRangeMin': widget.enabledRange!.$1,
        'enabledRangeMax': widget.enabledRange!.$2,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NKPlatformBuilder(
        iosBuilder: (context) => UiKitView(
          viewType: 'native_kit/slider_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (context) => CupertinoSlider(
          value: widget.value,
          onChanged: widget.enabled ? widget.onChanged : null,
          onChangeStart: widget.enabled ? widget.onChangeStart : null,
          onChangeEnd: widget.enabled ? widget.onChangeEnd : null,
          min: widget.min,
          max: widget.max,
          divisions: widget.step != null
              ? ((widget.max - widget.min) / widget.step!).round()
              : null,
          activeColor: widget.activeColor,
          thumbColor: widget.thumbColor ?? CupertinoColors.white,
        ),
      ),
    );
  }
}
