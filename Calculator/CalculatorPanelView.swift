import SwiftUI

/// One complete calculator (display + keypad) with its own view model.
/// Used singly by the main layout and twice by Duo mode.
struct CalculatorPanelView: View {
    @Environment(HistoryStore.self) private var historyStore
    @State private var viewModel: CalculatorViewModel

    private let spacing: CGFloat = 14

    private let rows: [[CalculatorKey]] = [
        [.clear, .toggleSign, .percent, .operation(.divide)],
        [.digit(7), .digit(8), .digit(9), .operation(.multiply)],
        [.digit(4), .digit(5), .digit(6), .operation(.subtract)],
        [.digit(1), .digit(2), .digit(3), .operation(.add)],
        [.digit(0), .decimal, .equals]
    ]

    init(history: HistoryStore) {
        _viewModel = State(initialValue: CalculatorViewModel(history: history))
    }

    var body: some View {
        GeometryReader { proxy in
            let size = buttonSize(for: proxy.size)
            let keypadWidth = size * 4 + spacing * 3
            VStack(spacing: spacing) {
                Spacer(minLength: 0)

                display(width: keypadWidth, size: size)

                keypad(size: size)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, spacing)
        }
        .onChange(of: historyStore.loadRequestID) { _, _ in
            if let text = historyStore.loadText {
                viewModel.loadValue(text)
            }
        }
    }

    // MARK: - Display

    private func display(width: CGFloat, size: CGFloat) -> some View {
        Text(viewModel.displayText)
            .font(.system(size: size * 1.1, weight: .light))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .padding(.horizontal, size * 0.25)
            .padding(.vertical, size * 0.12)
            .frame(width: width, alignment: .trailing)
            .modifier(GlassDisplayBackground())
    }

    // MARK: - Keypad

    @ViewBuilder
    private func keypad(size: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 4) {
                keypadRows(size: size)
            }
        } else {
            keypadRows(size: size)
        }
    }

    private func keypadRows(size: CGFloat) -> some View {
        VStack(spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { key in
                        button(for: key, size: size)
                    }
                }
            }
        }
    }

    private func buttonSize(for size: CGSize) -> CGFloat {
        let fitsWidth = (size.width - spacing * 5) / 4
        let fitsHeight = (size.height - spacing * 7) / 6.5
        return max(0, min(fitsWidth, fitsHeight))
    }

    private func button(for key: CalculatorKey, size: CGFloat) -> some View {
        CalculatorButton(
            title: title(for: key),
            kind: kind(for: key),
            isHighlighted: isHighlighted(key),
            size: size,
            width: key == .digit(0) ? size * 2 + spacing : nil
        ) {
            viewModel.press(key)
            Haptics.tap(for: key)
            if viewModel.displayText == "bruh" || viewModel.displayText == "Error" {
                Haptics.error()
            } else if key == .equals {
                Haptics.success()
            }
        }
    }

    private func title(for key: CalculatorKey) -> CalculatorButton.Title {
        switch key {
        case .digit(let digit): .text(String(digit))
        case .decimal: .text(".")
        case .clear: .text(viewModel.clearLabel)
        case .toggleSign: .symbol("plus.forwardslash.minus")
        case .percent: .symbol("percent")
        case .equals: .symbol("equal")
        case .operation(let operation): .symbol(operation.symbolName)
        }
    }

    private func kind(for key: CalculatorKey) -> CalculatorButton.Kind {
        switch key {
        case .digit, .decimal: .digit
        case .clear, .toggleSign, .percent: .function
        case .operation, .equals: .operation
        }
    }

    private func isHighlighted(_ key: CalculatorKey) -> Bool {
        if case .operation(let operation) = key {
            return operation == viewModel.activeOperation
        }
        return false
    }
}

/// Liquid Glass panel behind the display on iOS 26+,
/// ultra-thin material on earlier versions.
private struct GlassDisplayBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(
                .regular.tint(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.04)
                ),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
        } else {
            content.background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
        }
    }
}

extension CalculatorOperation {
    var symbolName: String {
        switch self {
        case .add: "plus"
        case .subtract: "minus"
        case .multiply: "multiply"
        case .divide: "divide"
        }
    }
}
