import SwiftUI

/// Duo mode: two fully independent calculators side by side,
/// sharing one history store. Best in landscape or on iPad;
/// in portrait the two panels stack.
struct DuoCalculatorView: View {
    @Environment(HistoryStore.self) private var history
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if proxy.size.width > proxy.size.height || proxy.size.width >= 700 {
                    HStack(spacing: 0) {
                        CalculatorPanelView(history: history)
                        Divider()
                        CalculatorPanelView(history: history)
                    }
                } else {
                    VStack(spacing: 0) {
                        CalculatorPanelView(history: history)
                        Divider()
                        CalculatorPanelView(history: history)
                    }
                }
            }
            .background {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(white: 0.10), Color.black]
                        : [Color(white: 0.98), Color(white: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Duo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
