import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard hex.count == 6, Scanner(string: hex).scanHexInt64(&int) else { return nil }
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let cgColor = UIColor(self).cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil),
              let components = cgColor.components,
              components.count >= 3 else {
            return "#000000"
        }
        let r = lroundf(Float(components[0]) * 255)
        let g = lroundf(Float(components[1]) * 255)
        let b = lroundf(Float(components[2]) * 255)
        return String(format: "#%02lX%02lX%02lX", r, g, b)
    }
}
