import SwiftUI

/// A calculator key rendered with native Liquid Glass on iOS 26+,
/// falling back to adaptive solid / material fills on iOS 17-25.
/// Colours adapt automatically to Light and Dark Mode.
struct CalculatorButton: View {
    enum Title {
        case text(String)
        case symbol(String)
    }

    enum Kind {
        case digit, function, operation
    }

    @Environment(\.colorScheme) private var colorScheme

    let title: Title
    var kind: Kind = .digit
    var isHighlighted = false
    var size: CGFloat = 80
    var width: CGFloat? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            label
                .frame(width: size, height: size)
                .frame(width: width ?? size, height: size, alignment: .leading)
                .foregroundStyle(foregroundColor)
                .modifier(GlassKeyBackground(
                    tint: glassTint,
                    fallback: fallbackColor,
                    isHighlighted: isHighlighted
                ))
                .contentShape(Capsule())
        }
        .buttonStyle(PressHighlightStyle())
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }

    @ViewBuilder
    private var label: some View {
        switch title {
        case .text(let text):
            Text(text)
                .font(.system(size: size * 0.42))
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: size * 0.36, weight: .semibold))
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .digit, .function:
            return .primary
        case .operation:
            return isHighlighted ? .calculatorOrange : .white
        }
    }

    /// Translucent tint used by Liquid Glass (iOS 26+).
    private var glassTint: Color {
        switch kind {
        case .digit:
            return colorScheme == .dark
                ? Color.white.opacity(0.14)
                : Color.black.opacity(0.06)
        case .function:
            return colorScheme == .dark
                ? Color.white.opacity(0.32)
                : Color.black.opacity(0.14)
        case .operation:
            return isHighlighted
                ? (colorScheme == .dark ? Color.white : Color.white)
                : Color.calculatorOrange.opacity(0.85)
        }
    }

    /// Solid fill used before iOS 26, and the colour the glass sits over.
    private var fallbackColor: Color {
        switch kind {
        case .digit:
            return colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.93)
        case .function:
            return colorScheme == .dark ? Color(white: 0.38) : Color(white: 0.82)
        case .operation:
            return isHighlighted ? Color(.systemBackground) : .calculatorOrange
        }
    }

    private struct PressHighlightStyle: ButtonStyle {
        @ViewBuilder
        func makeBody(configuration: Configuration) -> some View {
            if #available(iOS 26.0, *) {
                // Interactive Liquid Glass already provides press feedback;
                // adding brightness/scale here would double the effect
                // (Claude review fix).
                configuration.label
            } else {
                configuration.label
                    .brightness(configuration.isPressed ? 0.12 : 0)
                    .scaleEffect(configuration.isPressed ? 0.96 : 1)
                    .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            }
        }
    }
}

/// Applies native Liquid Glass on iOS 26+, otherwise a material-backed
/// solid capsule in the same shape.
private struct GlassKeyBackground: ViewModifier {
    let tint: Color
    let fallback: Color
    let isHighlighted: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(
                .regular.tint(tint).interactive(),
                in: Capsule()
            )
        } else {
            content.background(fallback, in: Capsule())
        }
    }
}

extension Color {
    static let calculatorOrange = Color(red: 1.0, green: 0.62, blue: 0.04)
}
