import SwiftUI

/// Adaptive root layout:
/// - Compact / portrait iPhone: one calculator, tools in toolbar sheets.
/// - Wide screens, iPad, and iPhone landscape: "Duo layout" — calculator
///   on the left with a companion panel (History / Converter / Settings)
///   on the right.
struct ContentView: View {
    @Environment(HistoryStore.self) private var history
    @Environment(\.colorScheme) private var colorScheme

    /// Held here in the root — not inside the panel — so switching between
    /// the single and Duo layouts on rotation keeps the calculation.
    @State private var mainViewModel: CalculatorViewModel

    init(history: HistoryStore) {
        _mainViewModel = State(initialValue: CalculatorViewModel(history: history))
    }

    @State private var activeSheet: RootSheet?
    @State private var showDuo = false
    @State private var companionTab: CompanionTab = .history

    private enum RootSheet: String, Identifiable {
        case history, converter, settings
        var id: String { rawValue }
    }

    private enum CompanionTab: String, CaseIterable, Identifiable {
        case history, converter, settings
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }

    var body: some View {
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 680
                || (proxy.size.width > proxy.size.height && proxy.size.height <= 450)
            if isWideLayout {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        toolbarRow
                        CalculatorPanelView(viewModel: mainViewModel)
                    }
                    .frame(maxWidth: 560)
                    Divider()
                    companionPanel
                        .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    toolbarRow
                    CalculatorPanelView(viewModel: mainViewModel)
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
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                sheetContent(sheet)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { activeSheet = nil }
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showDuo) {
            DuoCalculatorView(history: history)
        }
    }

    // MARK: - Toolbar

    private var toolbarRow: some View {
        HStack(spacing: 10) {
            toolbarButton("clock.arrow.circlepath", label: "History") { activeSheet = .history }
            toolbarButton("arrow.left.arrow.right", label: "Converter") { activeSheet = .converter }
            toolbarButton("rectangle.split.2x1", label: "Duo") { showDuo = true }
            Spacer()
            toolbarButton("gearshape", label: "Settings") { activeSheet = .settings }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private func toolbarButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.body.weight(.medium))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background(.ultraThinMaterial, in: Circle())
        .accessibilityLabel(label)
    }

    // MARK: - Sheets & companion panel

    @ViewBuilder
    private func sheetContent(_ sheet: RootSheet) -> some View {
        switch sheet {
        case .history:
            HistoryView { activeSheet = nil }
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.inline)
        case .converter:
            ConverterView()
                .navigationTitle("Converter")
                .navigationBarTitleDisplayMode(.inline)
        case .settings:
            SettingsView { showDuo = true }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var companionPanel: some View {
        VStack(spacing: 0) {
            Picker("Panel", selection: $companionTab) {
                ForEach(CompanionTab.allCases) { tab in
                    Text(tab.label).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(12)

            switch companionTab {
            case .history:
                HistoryView()
            case .converter:
                ConverterView()
            case .settings:
                SettingsView { showDuo = true }
            }
        }
    }
}
