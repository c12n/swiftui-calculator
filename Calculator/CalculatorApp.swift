import SwiftUI

@main
struct CalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            // No preferredColorScheme: the app follows the system
            // Light / Dark Mode setting natively.
            ContentView()
        }
    }
}
