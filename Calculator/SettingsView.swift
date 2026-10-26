import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct AppIconOption: Identifiable {
    let name: String        // Display name
    let iconName: String?   // nil = primary icon; otherwise the appiconset name
    let operationColor: Color
    var id: String { name }
}

/// Settings: appearance, accent colour (color picker), app icon changing,
/// haptics, and Duo mode.
struct SettingsView: View {
    @AppStorage("appearance") private var appearanceRaw = AppearanceChoice.system.rawValue
    @AppStorage("accentHex") private var accentHex = AccentTheme.defaultHex
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    var onOpenDuo: (() -> Void)? = nil

    private let iconOptions: [AppIconOption] = [
        .init(name: "Classic Orange", iconName: nil, operationColor: Color(hex: "#FF9E0A")),
        .init(name: "Blue", iconName: "AppIconBlue", operationColor: Color(hex: "#0A84FF")),
        .init(name: "Green", iconName: "AppIconGreen", operationColor: Color(hex: "#30D158")),
        .init(name: "Purple", iconName: "AppIconPurple", operationColor: Color(hex: "#BF5AF2")),
        .init(name: "Mono", iconName: "AppIconMono", operationColor: Color(hex: "#E8E8E8"))
    ]

    @State private var currentIconName: String? = nil
    @State private var iconError: String? = nil

    private var accentColor: Binding<Color> {
        Binding(
            get: { Color(hex: accentHex) },
            set: { accentHex = $0.hexString }
        )
    }

    private var appearance: Binding<AppearanceChoice> {
        Binding(
            get: { AppearanceChoice(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Mode", selection: appearance) {
                    ForEach(AppearanceChoice.allCases) { choice in
                        Text(choice.label).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Accent Colour") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                    ForEach(AccentTheme.presets.indices, id: \.self) { index in
                        let preset = AccentTheme.presets[index]
                        Button {
                            accentHex = preset.hex
                        } label: {
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if accentHex.caseInsensitiveCompare(preset.hex) == .orderedSame {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(preset.name)
                    }
                }
                ColorPicker("Custom Colour", selection: accentColor, supportsOpacity: false)
                HStack {
                    Text("Preview")
                    Spacer()
                    Text("÷  ×  −  +  =")
                        .font(.headline)
                        .foregroundStyle(Color(hex: accentHex))
                }
            }

            Section("App Icon") {
                ForEach(iconOptions) { option in
                    Button {
                        selectIcon(option.iconName)
                    } label: {
                        HStack(spacing: 12) {
                            iconPreview(color: option.operationColor)
                            Text(option.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if currentIconName == option.iconName {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: accentHex))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if let iconError {
                    Text(iconError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else {
                    Text("Changes the Home Screen icon. Takes effect immediately.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Feedback") {
                Toggle("Haptics", isOn: $hapticsEnabled)
            }

            if let onOpenDuo {
                Section("Duo") {
                    Button {
                        onOpenDuo()
                    } label: {
                        Label("Open Duo — Two Calculators", systemImage: "rectangle.split.2x1")
                    }
                }
            }

            Section("About") {
                LabeledContent("Version", value: "1.1.1")
                LabeledContent("License", value: "MIT")
                LabeledContent("Copyright", value: "© 2026 c12n Apps")
            }
        }
        .onAppear {
            #if canImport(UIKit)
            currentIconName = UIApplication.shared.alternateIconName
            #endif
        }
    }

    private func iconPreview(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(Color(white: 0.14))
            .frame(width: 40, height: 40)
            .overlay {
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(white: 0.35))
                        .frame(width: 26, height: 8)
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle().fill(Color(white: 0.4)).frame(width: 6, height: 6)
                        }
                        Circle().fill(color).frame(width: 6, height: 6)
                    }
                }
            }
    }

    private func selectIcon(_ name: String?) {
        #if canImport(UIKit)
        guard UIApplication.shared.supportsAlternateIcons else {
            iconError = "Alternate icons are not supported on this device."
            return
        }
        UIApplication.shared.setAlternateIconName(name) { error in
            Task { @MainActor in
                if let error {
                    iconError = error.localizedDescription
                } else {
                    iconError = nil
                    currentIconName = name
                }
            }
        }
        #endif
    }
}
