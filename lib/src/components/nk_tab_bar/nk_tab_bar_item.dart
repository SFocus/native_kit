import 'package:flutter/material.dart';
import '../../models/nk_image_source.dart';

/// Represents a single item in the NKTabBar.
class NKTabBarItem {
  /// The title text displayed below the icon.
  final String title;

  /// The icon to display (SF Symbol or custom image).
  final NKImageSource? icon;

  /// Optional selected state icon (used when tab is active).
  final NKImageSource? selectedIcon;

  /// Optional badge text to display on the item.
  final String? badge;

  /// Optional custom color for this specific item.
  final Color? customColor;

  /// Whether this is a custom action button (doesn't switch tabs).
  final bool isCustomButton;

  const NKTabBarItem({
    required this.title,
    this.icon,
    this.selectedIcon,
    this.badge,
    this.customColor,
    this.isCustomButton = false,
  });

  /// Creates a custom action button (like Instagram's center "+" button).
  ///
  /// Note: Custom buttons remain in the unselected state and don't change
  /// appearance when tapped. They trigger an action without switching tabs.
  const NKTabBarItem.customButton({
    required NKImageSource this.icon,
    String? title,
  }) : title = title ?? '',
       selectedIcon = null,
       badge = null,
       customColor = null,
       isCustomButton = true;

  /// Converts the item to a map for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (icon != null) 'icon': icon!.toMap(),
      if (selectedIcon != null) 'selectedIcon': selectedIcon!.toMap(),
      if (badge != null) 'badge': badge,
      if (customColor != null) 'customColor': customColor!.toARGB32(),
      'isCustomButton': isCustomButton,
    };
  }

  /// Creates a copy of this item with updated fields.
  NKTabBarItem copyWith({
    String? title,
    NKImageSource? icon,
    NKImageSource? selectedIcon,
    String? badge,
    Color? customColor,
    bool? isCustomButton,
  }) {
    return NKTabBarItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      badge: badge ?? this.badge,
      customColor: customColor ?? this.customColor,
      isCustomButton: isCustomButton ?? this.isCustomButton,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NKTabBarItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          icon == other.icon &&
          selectedIcon == other.selectedIcon &&
          badge == other.badge &&
          customColor == other.customColor &&
          isCustomButton == other.isCustomButton;

  @override
  int get hashCode => Object.hash(
    title,
    icon,
    selectedIcon,
    badge,
    customColor,
    isCustomButton,
  );
}
