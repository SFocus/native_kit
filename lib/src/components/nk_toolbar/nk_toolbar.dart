import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../models/nk_image_source.dart';
import '../../models/nk_text_style.dart';
import '../../models/nk_theme.dart';
import '../../utilities/nk_platform_builder.dart';
import '../../utilities/nk_platform_view_mixin.dart';

/// A single action item displayed in the toolbar.
class NKToolbarItem {
  /// Optional text label.
  final String? label;

  /// Optional icon (SF Symbol or custom image).
  final NKImageSource? icon;

  /// Called when the item is tapped.
  final VoidCallback? onPressed;

  /// Optional tint color.
  final Color? tintColor;

  /// Whether this item is enabled.
  final bool enabled;

  const NKToolbarItem({
    this.label,
    this.icon,
    this.onPressed,
    this.tintColor,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() => {
        if (label != null) 'label': label,
        if (icon != null) 'icon': icon!.toMap(),
        if (tintColor != null) 'tintColor': tintColor!.toARGB32(),
        'enabled': enabled,
      };
}

/// Configuration for a search bar integrated into the toolbar.
///
/// When provided to [NKToolbar] or [SliverNKToolbar], a native
/// `UISearchBar` is added to the navigation bar.
class NKSearchBarConfig {
  /// Placeholder text shown when the search field is empty.
  final String? placeholder;

  /// Called as the user types in the search field.
  final ValueChanged<String>? onChanged;

  /// Called when the user taps the search/return key.
  final ValueChanged<String>? onSubmitted;

  /// Called when the cancel button is tapped.
  final VoidCallback? onCancelPressed;

  /// Whether the search bar hides when scrolling (SliverNKToolbar only).
  final bool hidesWhenScrolling;

  /// Scope button titles for filtering search results.
  final List<String> scopeTitles;

  /// Called when the selected scope changes.
  final ValueChanged<int>? onScopeChanged;

  const NKSearchBarConfig({
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onCancelPressed,
    this.hidesWhenScrolling = true,
    this.scopeTitles = const [],
    this.onScopeChanged,
  });

  Map<String, dynamic> toMap() => {
        if (placeholder != null) 'placeholder': placeholder,
        'hidesWhenScrolling': hidesWhenScrolling,
        if (scopeTitles.isNotEmpty) 'scopeTitles': scopeTitles,
      };
}

/// Controls the navigation bar background appearance.
enum NKToolbarAppearance {
  /// Default system appearance (opaque background with separator).
  defaultAppearance,

  /// Transparent background with no separator.
  transparent,

  /// Opaque background with custom or default color.
  opaque,
}

// ---------------------------------------------------------------------------
// NKToolbar — fixed-height PreferredSizeWidget for Scaffold.appBar
// ---------------------------------------------------------------------------

/// A native iOS navigation bar with title, back button, and trailing actions.
///
/// On iOS 18+, renders a real `UINavigationBar`. On iOS 26+, the bar
/// automatically adopts Liquid Glass styling.
/// Falls back to a `CupertinoNavigationBar` on other platforms.
///
/// Use as `Scaffold.appBar` since it implements [PreferredSizeWidget].
///
/// For collapsible large titles that shrink on scroll, use
/// [SliverNKToolbar] inside a [CustomScrollView] instead.
///
/// **Standard toolbar** (default):
/// ```dart
/// Scaffold(
///   appBar: NKToolbar(
///     title: 'My Screen',
///     onBackPressed: () => Navigator.pop(context),
///     trailingItems: [
///       NKToolbarItem(
///         icon: NKSFSymbols.heart,
///         onPressed: () => print('Like'),
///       ),
///     ],
///   ),
///   body: ...,
/// )
/// ```
///
/// **Large title** (collapsible on scroll):
/// ```dart
/// Scaffold(
///   body: CustomScrollView(
///     slivers: [
///       SliverNKToolbar(
///         title: 'Settings',
///         onBackPressed: () => Navigator.pop(context),
///       ),
///       SliverList(
///         delegate: SliverChildListDelegate([...]),
///       ),
///     ],
///   ),
/// )
/// ```
class NKToolbar extends StatefulWidget implements PreferredSizeWidget {
  /// The title displayed in the navigation bar.
  final String? title;

  /// Whether to use large title display mode (static, non-collapsible).
  ///
  /// Disabled by default. For collapsible large titles that shrink on
  /// scroll, use [SliverNKToolbar] in a [CustomScrollView] instead.
  final bool prefersLargeTitles;

  /// Called when the back button is tapped. If null, no back button is shown.
  final VoidCallback? onBackPressed;

  /// Text label for the back button. Defaults to 'Back'.
  /// Only used when [onBackPressed] is not null.
  final String? backButtonTitle;

  /// Optional custom leading item (replaces the back button).
  final NKToolbarItem? leadingItem;

  /// Action items displayed on the trailing (right) side.
  /// Items are rendered left-to-right as specified (first item = leftmost).
  final List<NKToolbarItem> trailingItems;

  /// Optional global tint color for the bar and its items.
  final Color? tintColor;

  /// Optional background color for the navigation bar.
  final Color? backgroundColor;

  /// The background appearance style.
  final NKToolbarAppearance appearance;

  /// Whether to show the bottom separator line.
  final bool showSeparator;

  /// The height of the navigation bar content (excluding status bar).
  final double height;

  /// Optional search bar configuration. If set, a native search bar is
  /// added below the navigation bar title.
  final NKSearchBarConfig? searchBar;

  /// Text style for the navigation bar title (font family, size, weight).
  final NKTextStyle? titleTextStyle;

  const NKToolbar({
    super.key,
    this.title,
    this.prefersLargeTitles = false,
    this.onBackPressed,
    this.backButtonTitle,
    this.leadingItem,
    this.trailingItems = const [],
    this.tintColor,
    this.backgroundColor,
    this.appearance = NKToolbarAppearance.defaultAppearance,
    this.showSeparator = true,
    this.height = 44.0,
    this.searchBar,
    this.titleTextStyle,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(prefersLargeTitles ? 96.0 : height);

  @override
  State<NKToolbar> createState() => _NKToolbarState();
}

class _NKToolbarState extends State<NKToolbar>
    with NKPlatformViewMixin<NKToolbar> {
  @override
  String get channelPrefix => 'native_kit/toolbar';

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onBackPressed':
        widget.onBackPressed?.call();
      case 'onLeadingPressed':
        widget.leadingItem?.onPressed?.call();
      case 'onTrailingPressed':
        if (call.arguments is int) {
          final index = call.arguments as int;
          if (index >= 0 && index < widget.trailingItems.length) {
            widget.trailingItems[index].onPressed?.call();
          }
        }
      case 'onSearchChanged':
        if (call.arguments is String) {
          widget.searchBar?.onChanged?.call(call.arguments as String);
        }
      case 'onSearchSubmitted':
        if (call.arguments is String) {
          widget.searchBar?.onSubmitted?.call(call.arguments as String);
        }
      case 'onSearchCancelled':
        widget.searchBar?.onCancelPressed?.call();
      case 'onScopeChanged':
        if (call.arguments is int) {
          widget.searchBar?.onScopeChanged?.call(call.arguments as int);
        }
    }
  }

  @override
  void didUpdateWidget(NKToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.prefersLargeTitles != widget.prefersLargeTitles ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.appearance != widget.appearance ||
        oldWidget.showSeparator != widget.showSeparator ||
        oldWidget.backButtonTitle != widget.backButtonTitle ||
        oldWidget.titleTextStyle != widget.titleTextStyle ||
        oldWidget.trailingItems.length != widget.trailingItems.length ||
        (oldWidget.onBackPressed == null) !=
            (widget.onBackPressed == null) ||
        (oldWidget.leadingItem == null) != (widget.leadingItem == null) ||
        (oldWidget.searchBar == null) != (widget.searchBar == null)) {
      _update();
      return;
    }
    for (int i = 0; i < widget.trailingItems.length; i++) {
      if (oldWidget.trailingItems[i].toMap().toString() !=
          widget.trailingItems[i].toMap().toString()) {
        _update();
        return;
      }
    }
  }

  Future<void> _update() async {
    try {
      final theme = context.mounted ? NKTheme.of(context) : null;
      await channel?.invokeMethod('update', _buildCreationParams(theme));
    } catch (e) {
      debugPrint('NKToolbar: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams(NKThemeData? theme) {
    final effectiveTitleTextStyle = widget.titleTextStyle ?? theme?.textStyle;
    final effectiveTintColor = widget.tintColor ?? theme?.tintColor;

    return {
      if (widget.title != null) 'title': widget.title,
      'prefersLargeTitles': widget.prefersLargeTitles,
      'showBackButton': widget.onBackPressed != null,
      if (widget.backButtonTitle != null)
        'backButtonTitle': widget.backButtonTitle,
      if (widget.leadingItem != null)
        'leadingItem': widget.leadingItem!.toMap(),
      'trailingItems':
          widget.trailingItems.reversed.map((item) => item.toMap()).toList(),
      if (effectiveTintColor != null)
        'tintColor': effectiveTintColor.toARGB32(),
      if (widget.backgroundColor != null)
        'backgroundColor': widget.backgroundColor!.toARGB32(),
      'appearance': widget.appearance.name,
      'showSeparator': widget.showSeparator,
      'height': widget.prefersLargeTitles ? 96.0 : widget.height,
      if (widget.searchBar != null) 'searchBar': widget.searchBar!.toMap(),
      if (effectiveTitleTextStyle != null)
        'titleTextStyle': effectiveTitleTextStyle.toMap(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = NKTheme.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final barHeight = widget.prefersLargeTitles ? 96.0 : widget.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding),
        SizedBox(
          height: barHeight,
          child: NKPlatformBuilder(
            iosBuilder: (_) => UiKitView(
              viewType: 'native_kit/toolbar_view',
              creationParams: _buildCreationParams(theme),
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: onPlatformViewCreated,
              gestureRecognizers: eagerGestureRecognizers,
            ),
            fallbackBuilder: (_) => _buildFallback(),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return CupertinoNavigationBar(
      middle: widget.title != null ? Text(widget.title!) : null,
      backgroundColor: widget.backgroundColor,
      border: widget.showSeparator
          ? const Border(
              bottom:
                  BorderSide(color: CupertinoColors.separator, width: 0.0),
            )
          : null,
      leading: widget.onBackPressed != null
          ? CupertinoNavigationBarBackButton(
              previousPageTitle: widget.backButtonTitle ?? 'Back',
              onPressed: widget.onBackPressed,
            )
          : widget.leadingItem != null
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.leadingItem!.onPressed,
                  child: Text(widget.leadingItem!.label ?? ''),
                )
              : null,
      trailing: widget.trailingItems.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.trailingItems.map((item) {
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: item.enabled ? item.onPressed : null,
                  child: item.icon != null
                      ? Icon(CupertinoIcons.circle,
                          color: item.tintColor ?? widget.tintColor)
                      : Text(item.label ?? '',
                          style: TextStyle(
                              color: item.tintColor ?? widget.tintColor)),
                );
              }).toList(),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// SliverNKToolbar — collapsible large title for CustomScrollView
// ---------------------------------------------------------------------------

/// A sliver-based native iOS navigation bar with collapsible large titles.
///
/// Use inside a [CustomScrollView] for proper scroll-to-collapse behavior.
/// The bar pins at 44pt when scrolled, expanding to show a large title at rest.
///
/// Example:
/// ```dart
/// Scaffold(
///   body: CustomScrollView(
///     slivers: [
///       SliverNKToolbar(
///         title: 'Settings',
///         onBackPressed: () => Navigator.pop(context),
///         trailingItems: [
///           NKToolbarItem(label: 'Done', onPressed: () {}),
///         ],
///       ),
///       SliverList(
///         delegate: SliverChildListDelegate([...]),
///       ),
///     ],
///   ),
/// )
/// ```
class SliverNKToolbar extends StatelessWidget {
  /// The title displayed in both the large title area and the inline bar.
  final String? title;

  /// Called when the back button is tapped. If null, no back button is shown.
  final VoidCallback? onBackPressed;

  /// Text label for the back button. Defaults to 'Back'.
  final String? backButtonTitle;

  /// Optional custom leading item (replaces the back button).
  final NKToolbarItem? leadingItem;

  /// Action items displayed on the trailing (right) side.
  final List<NKToolbarItem> trailingItems;

  /// Optional global tint color for the bar and its items.
  final Color? tintColor;

  /// Optional background color for the navigation bar.
  final Color? backgroundColor;

  /// The background appearance style.
  final NKToolbarAppearance appearance;

  /// Optional search bar configuration.
  final NKSearchBarConfig? searchBar;

  /// Text style for the navigation bar title (font family, size, weight).
  final NKTextStyle? titleTextStyle;

  const SliverNKToolbar({
    super.key,
    this.title,
    this.onBackPressed,
    this.backButtonTitle,
    this.leadingItem,
    this.trailingItems = const [],
    this.tintColor,
    this.backgroundColor,
    this.appearance = NKToolbarAppearance.defaultAppearance,
    this.searchBar,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _NKToolbarSliverDelegate(
        topPadding: topPadding,
        title: title,
        onBackPressed: onBackPressed,
        backButtonTitle: backButtonTitle,
        leadingItem: leadingItem,
        trailingItems: trailingItems,
        tintColor: tintColor,
        backgroundColor: backgroundColor,
        appearance: appearance,
        searchBar: searchBar,
        titleTextStyle: titleTextStyle,
      ),
    );
  }
}

class _NKToolbarSliverDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String? title;
  final VoidCallback? onBackPressed;
  final String? backButtonTitle;
  final NKToolbarItem? leadingItem;
  final List<NKToolbarItem> trailingItems;
  final Color? tintColor;
  final Color? backgroundColor;
  final NKToolbarAppearance appearance;
  final NKSearchBarConfig? searchBar;
  final NKTextStyle? titleTextStyle;

  static const _navBarHeight = 44.0;
  static const _largeTitleHeight = 52.0;

  _NKToolbarSliverDelegate({
    required this.topPadding,
    this.title,
    this.onBackPressed,
    this.backButtonTitle,
    this.leadingItem,
    this.trailingItems = const [],
    this.tintColor,
    this.backgroundColor,
    this.appearance = NKToolbarAppearance.defaultAppearance,
    this.searchBar,
    this.titleTextStyle,
  });

  @override
  double get maxExtent => topPadding + _navBarHeight + _largeTitleHeight;

  @override
  double get minExtent => topPadding + _navBarHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _SliverNKToolbarContent(
      shrinkOffset: shrinkOffset,
      maxShrink: _largeTitleHeight,
      topPadding: topPadding,
      title: title,
      onBackPressed: onBackPressed,
      backButtonTitle: backButtonTitle,
      leadingItem: leadingItem,
      trailingItems: trailingItems,
      tintColor: tintColor,
      backgroundColor: backgroundColor,
      appearance: appearance,
      searchBar: searchBar,
      titleTextStyle: titleTextStyle,
    );
  }

  @override
  bool shouldRebuild(covariant _NKToolbarSliverDelegate oldDelegate) {
    return title != oldDelegate.title ||
        onBackPressed != oldDelegate.onBackPressed ||
        backButtonTitle != oldDelegate.backButtonTitle ||
        leadingItem != oldDelegate.leadingItem ||
        trailingItems.length != oldDelegate.trailingItems.length ||
        tintColor != oldDelegate.tintColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        appearance != oldDelegate.appearance ||
        searchBar != oldDelegate.searchBar ||
        titleTextStyle != oldDelegate.titleTextStyle ||
        topPadding != oldDelegate.topPadding;
  }
}

class _SliverNKToolbarContent extends StatefulWidget {
  final double shrinkOffset;
  final double maxShrink;
  final double topPadding;
  final String? title;
  final VoidCallback? onBackPressed;
  final String? backButtonTitle;
  final NKToolbarItem? leadingItem;
  final List<NKToolbarItem> trailingItems;
  final Color? tintColor;
  final Color? backgroundColor;
  final NKToolbarAppearance appearance;
  final NKSearchBarConfig? searchBar;
  final NKTextStyle? titleTextStyle;

  const _SliverNKToolbarContent({
    required this.shrinkOffset,
    required this.maxShrink,
    required this.topPadding,
    this.title,
    this.onBackPressed,
    this.backButtonTitle,
    this.leadingItem,
    this.trailingItems = const [],
    this.tintColor,
    this.backgroundColor,
    this.appearance = NKToolbarAppearance.defaultAppearance,
    this.searchBar,
    this.titleTextStyle,
  });

  @override
  State<_SliverNKToolbarContent> createState() =>
      _SliverNKToolbarContentState();
}

class _SliverNKToolbarContentState extends State<_SliverNKToolbarContent>
    with NKPlatformViewMixin<_SliverNKToolbarContent> {
  bool _showInlineTitle = false;

  @override
  String get channelPrefix => 'native_kit/toolbar';

  double get _collapseProgress =>
      (widget.shrinkOffset / widget.maxShrink).clamp(0.0, 1.0);

  @override
  Future<void> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onBackPressed':
        widget.onBackPressed?.call();
      case 'onLeadingPressed':
        widget.leadingItem?.onPressed?.call();
      case 'onTrailingPressed':
        if (call.arguments is int) {
          final index = call.arguments as int;
          if (index >= 0 && index < widget.trailingItems.length) {
            widget.trailingItems[index].onPressed?.call();
          }
        }
      case 'onSearchChanged':
        if (call.arguments is String) {
          widget.searchBar?.onChanged?.call(call.arguments as String);
        }
      case 'onSearchSubmitted':
        if (call.arguments is String) {
          widget.searchBar?.onSubmitted?.call(call.arguments as String);
        }
      case 'onSearchCancelled':
        widget.searchBar?.onCancelPressed?.call();
      case 'onScopeChanged':
        if (call.arguments is int) {
          widget.searchBar?.onScopeChanged?.call(call.arguments as int);
        }
    }
  }

  @override
  void didUpdateWidget(_SliverNKToolbarContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Toggle native inline title at threshold.
    final shouldShowInline = _collapseProgress >= 0.5;
    if (shouldShowInline != _showInlineTitle) {
      _showInlineTitle = shouldShowInline;
      _updateNative();
      return;
    }

    // Config changes.
    if (oldWidget.title != widget.title ||
        oldWidget.tintColor != widget.tintColor ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.appearance != widget.appearance ||
        oldWidget.backButtonTitle != widget.backButtonTitle ||
        oldWidget.trailingItems.length != widget.trailingItems.length ||
        (oldWidget.onBackPressed == null) !=
            (widget.onBackPressed == null) ||
        (oldWidget.leadingItem == null) != (widget.leadingItem == null) ||
        (oldWidget.searchBar == null) != (widget.searchBar == null)) {
      _updateNative();
    }
  }

  Future<void> _updateNative() async {
    try {
      final theme = context.mounted ? NKTheme.of(context) : null;
      await channel?.invokeMethod('update', _buildCreationParams(theme));
    } catch (e) {
      debugPrint('SliverNKToolbar: Failed to update: $e');
    }
  }

  Map<String, dynamic> _buildCreationParams(NKThemeData? theme) {
    final effectiveTitleTextStyle = widget.titleTextStyle ?? theme?.textStyle;
    final effectiveTintColor = widget.tintColor ?? theme?.tintColor;

    return {
      // Only show native inline title when the large title is collapsed.
      if (widget.title != null && _showInlineTitle) 'title': widget.title,
      'prefersLargeTitles': false,
      'showBackButton': widget.onBackPressed != null,
      if (widget.backButtonTitle != null)
        'backButtonTitle': widget.backButtonTitle,
      if (widget.leadingItem != null)
        'leadingItem': widget.leadingItem!.toMap(),
      'trailingItems':
          widget.trailingItems.reversed.map((item) => item.toMap()).toList(),
      if (effectiveTintColor != null)
        'tintColor': effectiveTintColor.toARGB32(),
      if (widget.backgroundColor != null)
        'backgroundColor': widget.backgroundColor!.toARGB32(),
      'appearance': widget.appearance.name,
      'showSeparator': false,
      'height': 44.0,
      if (widget.searchBar != null) 'searchBar': widget.searchBar!.toMap(),
      if (effectiveTitleTextStyle != null)
        'titleTextStyle': effectiveTitleTextStyle.toMap(),
    };
  }

  FontWeight _mapFontWeight(NKFontWeight? weight) {
    switch (weight) {
      case NKFontWeight.ultraLight:
        return FontWeight.w100;
      case NKFontWeight.thin:
        return FontWeight.w200;
      case NKFontWeight.light:
        return FontWeight.w300;
      case NKFontWeight.regular:
        return FontWeight.w400;
      case NKFontWeight.medium:
        return FontWeight.w500;
      case NKFontWeight.semibold:
        return FontWeight.w600;
      case NKFontWeight.bold:
        return FontWeight.w700;
      case NKFontWeight.heavy:
        return FontWeight.w800;
      case NKFontWeight.black:
        return FontWeight.w900;
      case null:
        return FontWeight.bold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _collapseProgress;
    final largeTitleOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    final largeTitleHeight = widget.maxShrink * (1.0 - progress);

    final theme = NKTheme.of(context);
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          SizedBox(height: widget.topPadding),
          SizedBox(
            height: 44.0,
            child: NKPlatformBuilder(
              iosBuilder: (_) => UiKitView(
                viewType: 'native_kit/toolbar_view',
                creationParams: _buildCreationParams(theme),
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: onPlatformViewCreated,
                gestureRecognizers: eagerGestureRecognizers,
              ),
              fallbackBuilder: (_) => _buildFallback(),
            ),
          ),
          SizedBox(
            height: largeTitleHeight,
            child: Opacity(
              opacity: largeTitleOpacity,
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    widget.title ?? '',
                    style: TextStyle(
                      fontSize: (widget.titleTextStyle ?? theme?.textStyle)?.fontSize ?? 34,
                      fontWeight:
                          _mapFontWeight((widget.titleTextStyle ?? theme?.textStyle)?.fontWeight),
                      fontFamily: (widget.titleTextStyle ?? theme?.textStyle)?.fontFamily,
                      letterSpacing: 0.37,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return CupertinoNavigationBar(
      middle: _showInlineTitle && widget.title != null
          ? Text(widget.title!)
          : null,
      backgroundColor: widget.backgroundColor,
      border: null,
      leading: widget.onBackPressed != null
          ? CupertinoNavigationBarBackButton(
              previousPageTitle: widget.backButtonTitle ?? 'Back',
              onPressed: widget.onBackPressed,
            )
          : widget.leadingItem != null
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.leadingItem!.onPressed,
                  child: Text(widget.leadingItem!.label ?? ''),
                )
              : null,
      trailing: widget.trailingItems.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.trailingItems.map((item) {
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: item.enabled ? item.onPressed : null,
                  child: item.icon != null
                      ? Icon(CupertinoIcons.circle,
                          color: item.tintColor ?? widget.tintColor)
                      : Text(item.label ?? '',
                          style: TextStyle(
                              color: item.tintColor ?? widget.tintColor)),
                );
              }).toList(),
            )
          : null,
    );
  }
}
