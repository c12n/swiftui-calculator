import SwiftUI

@main
struct CalculatorApp: App {
    @State private var history = HistoryStore()
    @AppStorage("appearance") private var appearanceRaw = AppearanceChoice.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(history)
                // Native Light/Dark Mode: follows the system setting by
                // default; the user can force Light or Dark in Settings.
                .preferredColorScheme(
                    (AppearanceChoice(rawValue: appearanceRaw) ?? .system).colorScheme
                )
        }
    }
}
