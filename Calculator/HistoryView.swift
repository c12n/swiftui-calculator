import SwiftUI

/// Calculation history list. Tap a result to load it into the calculator.
struct HistoryView: View {
    @Environment(HistoryStore.self) private var history
    @AppStorage("accentHex") private var accentHex = AccentTheme.defaultHex

    var onUse: (() -> Void)? = nil

    var body: some View {
        Group {
            if history.entries.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Results from “=” will appear here. Tap one to reuse it.")
                )
            } else {
                List {
                    ForEach(history.entries) { entry in
                        Button {
                            history.requestLoad(entry.result)
                            onUse?()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.expression)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("= \(entry.result)")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color(hex: accentHex))
                                    Spacer()
                                    Text(entry.date, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        history.remove(at: offsets)
                    }
                }
                .listStyle(.plain)
            }
        }
        .toolbar {
            if !history.entries.isEmpty {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear All", role: .destructive) {
                        history.clear()
                    }
                }
            }
        }
    }
}
