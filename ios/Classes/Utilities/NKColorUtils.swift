import UIKit

extension UIColor {
    /// Convert Flutter ARGB integer to UIColor.
    static func fromARGB(_ value: Int64) -> UIColor {
        let a = CGFloat((value >> 24) & 0xFF) / 255.0
        let r = CGFloat((value >> 16) & 0xFF) / 255.0
        let g = CGFloat((value >> 8) & 0xFF) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Convert UIColor to Flutter ARGB integer.
    func toARGB() -> Int64 {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int64(a * 255) << 24) |
               (Int64(r * 255) << 16) |
               (Int64(g * 255) << 8) |
               Int64(b * 255)
    }
}
