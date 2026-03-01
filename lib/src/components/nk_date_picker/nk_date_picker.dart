import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// The type of date/time selection.
enum NKDatePickerMode {
  /// Date only (year, month, day).
  date,

  /// Time only (hour, minute).
  time,

  /// Date and time combined.
  dateAndTime,

  /// Countdown timer duration.
  countdownTimer,
}

/// The visual presentation style of the picker.
enum NKDatePickerStyle {
  /// Compact label that expands on tap (44pt).
  compact,

  /// Inline calendar/time grid (~320pt).
  inline,

  /// Classic spinning wheels (~216pt).
  wheels,
}

/// A native iOS date picker.
///
/// Renders a `UIDatePicker` on iOS 18+ with support for all modes (date,
/// time, dateAndTime, countdownTimer) and styles (compact, inline, wheels).
/// On iOS 26+, the picker gets Liquid Glass styling automatically.
///
/// Falls back to [CupertinoDatePicker] on other platforms.
///
/// Example (inline date picker):
/// ```dart
/// NKDatePicker(
///   mode: NKDatePickerMode.date,
///   style: NKDatePickerStyle.inline,
///   initialDate: DateTime.now(),
///   onDateChanged: (date) => print(date),
/// )
/// ```
///
/// Example (compact date & time):
/// ```dart
/// NKDatePicker(
///   mode: NKDatePickerMode.dateAndTime,
///   style: NKDatePickerStyle.compact,
///   onDateChanged: (date) => setState(() => _selected = date),
/// )
/// ```
class NKDatePicker extends StatefulWidget {
  /// The type of date/time selection.
  final NKDatePickerMode mode;

  /// The visual presentation style.
  final NKDatePickerStyle style;

  /// Initial date value. Defaults to now.
  final DateTime? initialDate;

  /// Minimum selectable date.
  final DateTime? minimumDate;

  /// Maximum selectable date.
  final DateTime? maximumDate;

  /// Initial countdown duration (for [NKDatePickerMode.countdownTimer]).
  final Duration? countdownDuration;

  /// Minute interval for the picker (1–30).
  final int minuteInterval;

  /// Called when the selected date changes.
  final ValueChanged<DateTime>? onDateChanged;

  /// Called when the countdown duration changes.
  final ValueChanged<Duration>? onCountdownChanged;

  /// Tint color for the picker.
  final Color? tintColor;

  /// Override the default height for the picker.
  final double? height;

  const NKDatePicker({
    super.key,
    this.mode = NKDatePickerMode.date,
    this.style = NKDatePickerStyle.inline,
    this.initialDate,
    this.minimumDate,
    this.maximumDate,
    this.countdownDuration,
    this.minuteInterval = 1,
    this.onDateChanged,
    this.onCountdownChanged,
    this.tintColor,
    this.height,
  });

  @override
  State<NKDatePicker> createState() => _NKDatePickerState();
}

class _NKDatePickerState extends State<NKDatePicker>
    with NKPlatformViewMixin<NKDatePicker> {
  @override
  String get channelPrefix => 'native_kit/date_picker';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDateChanged':
        if (call.arguments is double) {
          final ms = (call.arguments as double).toInt();
          final date = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
          widget.onDateChanged?.call(date.toLocal());
        }
      case 'onCountdownChanged':
        if (call.arguments is double) {
          final seconds = (call.arguments as double).toInt();
          widget.onCountdownChanged?.call(Duration(seconds: seconds));
        }
    }
  }

  @override
  void didUpdateWidget(NKDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode ||
        oldWidget.style != widget.style ||
        oldWidget.minimumDate != widget.minimumDate ||
        oldWidget.maximumDate != widget.maximumDate ||
        oldWidget.minuteInterval != widget.minuteInterval ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.countdownDuration != widget.countdownDuration) {
      _update();
    }
  }

  Future<void> _update() async {
    try {
      await channel?.invokeMethod('update', _buildCreationParams());
    } catch (e) {
      debugPrint('NKDatePicker: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'mode': widget.mode.name,
      'style': widget.style.name,
      if (widget.initialDate != null)
        'initialDate':
            widget.initialDate!.toUtc().millisecondsSinceEpoch.toDouble(),
      if (widget.minimumDate != null)
        'minimumDate':
            widget.minimumDate!.toUtc().millisecondsSinceEpoch.toDouble(),
      if (widget.maximumDate != null)
        'maximumDate':
            widget.maximumDate!.toUtc().millisecondsSinceEpoch.toDouble(),
      if (widget.countdownDuration != null)
        'countdownDuration': widget.countdownDuration!.inSeconds.toDouble(),
      'minuteInterval': widget.minuteInterval,
      if (widget.tintColor != null) 'tintColor': widget.tintColor!.toARGB32(),
    };
  }

  double get _defaultHeight {
    if (widget.height != null) return widget.height!;
    switch (widget.style) {
      case NKDatePickerStyle.compact:
        return 44.0;
      case NKDatePickerStyle.inline:
        return 320.0;
      case NKDatePickerStyle.wheels:
        return 216.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _defaultHeight,
      child: NKPlatformBuilder(
        iosBuilder: (_) => UiKitView(
          viewType: 'native_kit/date_picker_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (_) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    if (widget.mode == NKDatePickerMode.countdownTimer) {
      return CupertinoTimerPicker(
        initialTimerDuration:
            widget.countdownDuration ?? const Duration(minutes: 1),
        minuteInterval: widget.minuteInterval,
        onTimerDurationChanged: (d) => widget.onCountdownChanged?.call(d),
      );
    }

    return CupertinoDatePicker(
      mode: _cupertinoMode,
      initialDateTime: widget.initialDate ?? DateTime.now(),
      minimumDate: widget.minimumDate,
      maximumDate: widget.maximumDate,
      minuteInterval: widget.minuteInterval,
      onDateTimeChanged: (d) => widget.onDateChanged?.call(d),
    );
  }

  CupertinoDatePickerMode get _cupertinoMode {
    switch (widget.mode) {
      case NKDatePickerMode.date:
        return CupertinoDatePickerMode.date;
      case NKDatePickerMode.time:
        return CupertinoDatePickerMode.time;
      case NKDatePickerMode.dateAndTime:
      case NKDatePickerMode.countdownTimer:
        return CupertinoDatePickerMode.dateAndTime;
    }
  }
}
