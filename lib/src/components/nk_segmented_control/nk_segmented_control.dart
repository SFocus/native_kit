import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/nk_sf_symbol.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// A native iOS-style segmented control widget.
///
/// Uses UIKit's UISegmentedControl on iOS for authentic native look and feel.
/// Falls back to [CupertinoSlidingSegmentedControl] on other platforms.
///
/// Example:
/// ```dart
/// NKSegmentedControl(
///   labels: ['Day', 'Week', 'Month'],
///   selectedIndex: _selectedIndex,
///   onValueChanged: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
///
/// With icons:
/// ```dart
/// NKSegmentedControl(
///   labels: ['List', 'Grid'],
///   icons: [NKSFSymbols.listBullet, NKSFSymbols.squareGrid2x2],
///   selectedIndex: _selectedIndex,
///   onValueChanged: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
class NKSegmentedControl extends StatefulWidget {
  /// The labels for each segment.
  final List<String> labels;

  /// Optional SF Symbol icons for each segment.
  ///
  /// If provided, must have the same length as [labels]. Use `null` entries
  /// for segments that should not have an icon.
  final List<NKSFSymbol?>? icons;

  /// The currently selected segment index.
  final int selectedIndex;

  /// Callback invoked when the selected segment changes.
  final ValueChanged<int>? onValueChanged;

  /// The tint color applied to the selected segment.
  final Color? tintColor;

  /// Whether the segmented control is enabled.
  final bool enabled;

  /// The height of the segmented control.
  final double height;

  const NKSegmentedControl({
    super.key,
    required this.labels,
    this.icons,
    this.selectedIndex = 0,
    this.onValueChanged,
    this.tintColor,
    this.enabled = true,
    this.height = 32.0,
  }) : assert(
          icons == null || icons.length == labels.length,
          'icons list must have the same length as labels',
        );

  @override
  State<NKSegmentedControl> createState() => _NKSegmentedControlState();
}

class _NKSegmentedControlState extends State<NKSegmentedControl>
    with NKPlatformViewMixin<NKSegmentedControl> {
  @override
  String get channelPrefix => 'native_kit/segmented_control';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onValueChanged' && call.arguments is int) {
      widget.onValueChanged?.call(call.arguments as int);
    }
  }

  @override
  void didUpdateWidget(NKSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _setSelectedIndex(widget.selectedIndex);
    }
    if (oldWidget.enabled != widget.enabled) {
      _setEnabled(widget.enabled);
    }
  }

  Future<void> _setSelectedIndex(int index) async {
    try {
      await channel?.invokeMethod('setSelectedIndex', {'index': index});
    } catch (e) {
      debugPrint('NKSegmentedControl: Failed to set selected index: $e');
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    try {
      await channel?.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (e) {
      debugPrint('NKSegmentedControl: Failed to set enabled: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams() {
    return {
      'labels': widget.labels,
      if (widget.icons != null)
        'icons': widget.icons!.map((icon) => icon?.toMap()).toList(),
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      if (widget.tintColor != null)
        'tintColor': widget.tintColor!.toARGB32(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: NKPlatformBuilder(
        iosBuilder: (_) => UiKitView(
          viewType: 'native_kit/segmented_control_view',
          creationParams: _buildCreationParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: eagerGestureRecognizers,
        ),
        fallbackBuilder: (_) => CupertinoSlidingSegmentedControl<int>(
          groupValue: widget.selectedIndex,
          thumbColor: widget.tintColor ?? CupertinoColors.white,
          onValueChanged: (int? value) {
            if (widget.enabled && value != null) {
              widget.onValueChanged?.call(value);
            }
          },
          children: {
            for (int i = 0; i < widget.labels.length; i++)
              i: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(widget.labels[i]),
              ),
          },
        ),
      ),
    );
  }
}
