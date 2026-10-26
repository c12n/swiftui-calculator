import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Accent colour theming, persisted as a hex string in @AppStorage("accentHex").
enum AccentTheme {
    static let defaultHex = "#FF9E0A"

    static let presets: [(name: String, hex: String)] = [
        ("Orange", "#FF9E0A"),
        ("Blue", "#0A84FF"),
        ("Green", "#30D158"),
        ("Purple", "#BF5AF2"),
        ("Pink", "#FF375F"),
        ("Teal", "#64D2FF"),
        ("Yellow", "#FFD60A"),
        ("Red", "#FF453A")
    ]
}

extension Color {
    init(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "#%02X%02X%02X",
            Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded())
        )
        #else
        return AccentTheme.defaultHex
        #endif
    }
}

/// User appearance choice, persisted in @AppStorage("appearance").
enum AppearanceChoice: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
