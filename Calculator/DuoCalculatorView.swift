import SwiftUI

/// Duo mode: two fully independent calculators side by side,
/// sharing one history store. Best in landscape or on iPad;
/// in portrait the two panels stack. The view models live here,
/// so rotating between the side-by-side and stacked arrangements
/// keeps both calculations.
struct DuoCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var firstViewModel: CalculatorViewModel
    @State private var secondViewModel: CalculatorViewModel

    init(history: HistoryStore) {
        _firstViewModel = State(initialValue: CalculatorViewModel(history: history))
        _secondViewModel = State(initialValue: CalculatorViewModel(history: history))
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if proxy.size.width > proxy.size.height || proxy.size.width >= 700 {
                    HStack(spacing: 0) {
                        CalculatorPanelView(viewModel: firstViewModel)
                        Divider()
                        CalculatorPanelView(viewModel: secondViewModel)
                    }
                } else {
                    VStack(spacing: 0) {
                        CalculatorPanelView(viewModel: firstViewModel)
                        Divider()
                        CalculatorPanelView(viewModel: secondViewModel)
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
