import UIKit
import CoreText

/// Utilities for font parsing and runtime font registration.
struct NKFontUtils {

    /// Bundle keys of fonts already registered to avoid double-registration.
    private static var registeredFonts = Set<String>()

    // MARK: - Font Registration

    /// Registers a font from the app bundle at runtime using CoreText.
    /// Returns `true` if registration succeeded or font was already registered.
    @discardableResult
    static func registerFont(at bundlePath: String) -> Bool {
        if registeredFonts.contains(bundlePath) { return true }

        guard let fontData = NSData(contentsOfFile: bundlePath),
              let provider = CGDataProvider(data: fontData),
              let font = CGFont(provider) else {
            return false
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        if success {
            registeredFonts.insert(bundlePath)
        }
        return success
    }

    // MARK: - Font Parsing

    /// Creates a `UIFont` from a text style dictionary received from Flutter.
    ///
    /// Dictionary keys:
    /// - `fontFamily` (String?): Font family name
    /// - `fontSize` (CGFloat?): Point size
    /// - `fontWeight` (String?): Weight name matching `NKFontWeight` enum
    ///
    /// Returns `nil` if the dictionary is `nil`.
    static func font(from dict: [String: Any]?, defaultSize: CGFloat = 17.0) -> UIFont? {
        guard let dict = dict else { return nil }

        let size = dict["fontSize"] as? CGFloat ?? defaultSize
        let weight = mapWeight(dict["fontWeight"] as? String)

        if let family = dict["fontFamily"] as? String {
            // Try as a specific font name (e.g., "Avenir-Heavy")
            if let font = UIFont(name: family, size: size) {
                return font
            }

            // Try as a font family, applying the requested weight via descriptor
            let descriptor = UIFontDescriptor()
                .withFamily(family)
                .addingAttributes([
                    .traits: [UIFontDescriptor.TraitKey.weight: weight]
                ])
            let font = UIFont(descriptor: descriptor, size: size)
            // UIFont(descriptor:size:) always returns a font; verify it matched the family
            if font.familyName.lowercased() == family.lowercased() {
                return font
            }

            // Family not found — fall back to system font with the requested weight
            return UIFont.systemFont(ofSize: size, weight: weight)
        }

        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    /// Builds `NSAttributedString.Key` attributes with the `.font` key set.
    /// Returns `nil` if the text style dictionary is `nil`.
    static func textAttributes(
        from dict: [String: Any]?,
        defaultSize: CGFloat = 17.0
    ) -> [NSAttributedString.Key: Any]? {
        guard let font = font(from: dict, defaultSize: defaultSize) else { return nil }
        return [.font: font]
    }

    // MARK: - Weight Mapping

    private static func mapWeight(_ name: String?) -> UIFont.Weight {
        switch name {
        case "ultraLight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "regular":    return .regular
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        case "black":      return .black
        default:           return .regular
        }
    }
}
