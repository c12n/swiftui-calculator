import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Lightweight haptic feedback. Respects the in-app Haptics setting.
enum Haptics {
    static var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: "hapticsEnabled") == nil { return true }
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    static func tap(for key: CalculatorKey) {
        guard isEnabled else { return }
        #if canImport(UIKit)
        switch key {
        case .digit, .decimal:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .operation, .toggleSign, .percent, .clear:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .equals:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        #endif
    }

    static func error() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }

    static func success() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}
