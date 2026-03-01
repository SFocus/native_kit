import UIKit

/// Shared utilities for creating and configuring Liquid Glass effects.
@available(iOS 26.0, *)
struct NKGlassUtils {

    /// Creates a `UIVisualEffectView` configured with `UIGlassEffect`.
    static func makeGlassView(
        style: String = "regular",
        isInteractive: Bool = false,
        tintColor: UIColor? = nil
    ) -> UIVisualEffectView {
        let glassStyle: UIGlassEffect.Style = style == "clear" ? .clear : .regular
        let effect = UIGlassEffect(style: glassStyle)
        effect.isInteractive = isInteractive
        if let tint = tintColor {
            effect.tintColor = tint
        }
        return UIVisualEffectView(effect: effect)
    }

    /// Applies corner configuration to a view.
    static func applyCornerConfiguration(
        to view: UIView,
        cornerRadius: CGFloat?,
        capsule: Bool
    ) {
        if capsule {
            view.cornerConfiguration = .capsule()
        } else if let radius = cornerRadius {
            view.cornerConfiguration = .corners(radius: .fixed(radius))
        }
    }

    /// Creates a `UIVisualEffectView` with `UIGlassContainerEffect` for grouping.
    static func makeGlassContainerView(
        spacing: CGFloat = 12.0
    ) -> UIVisualEffectView {
        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = spacing
        return UIVisualEffectView(effect: containerEffect)
    }
}
