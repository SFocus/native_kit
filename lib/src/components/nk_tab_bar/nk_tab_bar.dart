import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/nk_text_style.dart';
import '../../models/nk_theme.dart';
import '../../utilities/nk_platform_view_mixin.dart';
import 'nk_tab_bar_item.dart';

/// A native iOS-style bottom tab bar widget.
///
/// Uses UIKit's UITabBar on iOS for authentic native look and feel.
/// Part of the NativeKit library (NK prefix indicates NativeKit components).
///
/// Example:
/// ```dart
/// Scaffold(
///   body: IndexedStack(
///     index: _selectedIndex,
///     children: _pages,
///   ),
///   bottomNavigationBar: NKTabBar(
///     items: [
///       NKTabBarItem(
///         title: 'Home',
///         icon: NKSFSymbols.house,
///         selectedIcon: NKSFSymbols.houseFill,
///       ),
///       NKTabBarItem(
///         title: 'Profile',
///         icon: NKSFSymbols.person,
///       ),
///     ],
///     currentIndex: _selectedIndex,
///     onTap: (index) => setState(() => _selectedIndex = index),
///   ),
/// )
/// ```
class NKTabBar extends StatefulWidget {
  /// List of tab bar items to display.
  final List<NKTabBarItem> items;

  /// Current selected tab index.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int>? onTap;

  /// Callback when a custom button is tapped.
  final ValueChanged<int>? onCustomButtonTap;

  /// Background color of the tab bar.
  final Color? backgroundColor;

  /// Color of the selected item.
  final Color? selectedItemColor;

  /// Color of unselected items.
  final Color? unselectedItemColor;

  /// Height of the tab bar.
  final double? height;

  /// Whether the tab bar is visible.
  final bool isVisible;

  /// Text style for tab item labels (font family, size, weight).
  final NKTextStyle? textStyle;

  const NKTabBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.onCustomButtonTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height,
    this.isVisible = true,
    this.textStyle,
  });

  @override
  State<NKTabBar> createState() => _NKTabBarState();
}

class _NKTabBarState extends State<NKTabBar>
    with NKPlatformViewMixin<NKTabBar> {
  @override
  String get channelPrefix => 'native_kit/tab_bar';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    if (call.method == 'onTabSelected' && call.arguments is int) {
      widget.onTap?.call(call.arguments as int);
    } else if (call.method == 'onCustomButtonTap' && call.arguments is int) {
      widget.onCustomButtonTap?.call(call.arguments as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Validate that only one custom button exists
    final customButtonCount =
        widget.items.where((item) => item.isCustomButton).length;
    assert(
      customButtonCount <= 1,
      'Only one custom button is allowed in NKTabBar. Found $customButtonCount custom buttons.',
    );

    final theme = NKTheme.of(context);
    return SizedBox(
      height: (widget.height ?? 49.0) + MediaQuery.of(context).padding.bottom,
      child: UiKitView(
        viewType: 'native_kit/tab_bar_view',
        creationParams: _buildCreationParams(theme),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      ),
    );
  }

  Map<String, dynamic> _buildCreationParams(NKThemeData? theme) {
    final effectiveTextStyle = widget.textStyle ?? theme?.textStyle;

    return {
      'items': widget.items.map((item) => item.toMap()).toList(),
      'currentIndex': widget.currentIndex,
      if (widget.backgroundColor != null)
        'backgroundColor': widget.backgroundColor!.toARGB32(),
      if (widget.selectedItemColor != null)
        'selectedItemColor': widget.selectedItemColor!.toARGB32(),
      if (widget.unselectedItemColor != null)
        'unselectedItemColor': widget.unselectedItemColor!.toARGB32(),
      if (effectiveTextStyle != null) 'textStyle': effectiveTextStyle.toMap(),
    };
  }

  @override
  void didUpdateWidget(NKTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateSelectedIndex(widget.currentIndex);
    }

    if (oldWidget.isVisible != widget.isVisible) {
      _updateVisibility(widget.isVisible);
    }

    _updateBadgesIfNeeded(oldWidget);
  }

  void _updateBadgesIfNeeded(NKTabBar oldWidget) {
    for (var i = 0; i < widget.items.length; i++) {
      if (i < oldWidget.items.length &&
          oldWidget.items[i].badge != widget.items[i].badge) {
        _updateBadge(i, widget.items[i].badge);
      }
    }
  }

  Future<void> _updateVisibility(bool visible) async {
    try {
      await channel?.invokeMethod('setVisible', {'visible': visible});
    } catch (e) {
      debugPrint('Failed to update visibility: $e');
    }
  }

  Future<void> _updateSelectedIndex(int index) async {
    try {
      await channel?.invokeMethod('setSelectedIndex', {'index': index});
    } catch (e) {
      debugPrint('Failed to update selected index: $e');
    }
  }

  Future<void> _updateBadge(int index, String? badge) async {
    try {
      await channel?.invokeMethod(
        'setBadge',
        {'index': index, 'badge': badge},
      );
    } catch (e) {
      debugPrint('Failed to update badge: $e');
    }
  }
}
