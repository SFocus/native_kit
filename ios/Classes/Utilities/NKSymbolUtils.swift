import UIKit

struct NKSymbolUtils {
    /// Create a UIImage from an SF Symbol name with optional configuration.
    static func createImage(
        name: String,
        config: [String: Any]? = nil,
        pointSize: CGFloat? = nil,
        color: UIColor? = nil
    ) -> UIImage? {
        var symbolConfig = UIImage.SymbolConfiguration.unspecified

        if let configDict = config {
            if let weightStr = configDict["weight"] as? String {
                symbolConfig = symbolConfig.applying(
                    UIImage.SymbolConfiguration(weight: mapWeight(weightStr))
                )
            }
            if let scaleStr = configDict["scale"] as? String {
                symbolConfig = symbolConfig.applying(
                    UIImage.SymbolConfiguration(scale: mapScale(scaleStr))
                )
            }
        }

        if let size = pointSize {
            symbolConfig = symbolConfig.applying(
                UIImage.SymbolConfiguration(pointSize: size)
            )
        }

        var image = UIImage(systemName: name, withConfiguration: symbolConfig)

        if let tintColor = color {
            image = image?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }

        return image
    }

    /// Parse SF Symbol icon data from a Flutter creation params dictionary.
    static func parseIcon(from dict: [String: Any]?) -> (name: String, config: [String: Any]?)? {
        guard let iconDict = dict,
              iconDict["type"] as? String == "sf_symbol",
              let name = iconDict["name"] as? String else {
            return nil
        }
        return (name: name, config: iconDict["config"] as? [String: Any])
    }

    private static func mapWeight(_ s: String) -> UIImage.SymbolWeight {
        switch s {
        case "ultraLight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular
        }
    }

    private static func mapScale(_ s: String) -> UIImage.SymbolScale {
        switch s {
        case "small": return .small
        case "medium": return .medium
        case "large": return .large
        default: return .medium
        }
    }
}
