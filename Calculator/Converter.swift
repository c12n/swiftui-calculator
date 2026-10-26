import SwiftUI

// MARK: - Conversion data

enum ConversionCategory: String, CaseIterable, Identifiable {
    case length, weight, temperature, volume, speed, data, currency
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var units: [ConversionUnit] {
        switch self {
        case .length: return ConversionUnit.lengthUnits
        case .weight: return ConversionUnit.weightUnits
        case .temperature: return ConversionUnit.temperatureUnits
        case .volume: return ConversionUnit.volumeUnits
        case .speed: return ConversionUnit.speedUnits
        case .data: return ConversionUnit.dataUnits
        case .currency: return ConversionUnit.currencyUnits
        }
    }
}

struct ConversionUnit: Identifiable, Hashable {
    let name: String
    let symbol: String
    /// Multiplier to the category's base unit. For currency: units per 1 USD.
    /// Ignored for temperature, which converts via Celsius formulas.
    let toBase: Double
    var id: String { name }

    static let lengthUnits: [ConversionUnit] = [
        .init(name: "Millimetres", symbol: "mm", toBase: 0.001),
        .init(name: "Centimetres", symbol: "cm", toBase: 0.01),
        .init(name: "Metres", symbol: "m", toBase: 1),
        .init(name: "Kilometres", symbol: "km", toBase: 1000),
        .init(name: "Inches", symbol: "in", toBase: 0.0254),
        .init(name: "Feet", symbol: "ft", toBase: 0.3048),
        .init(name: "Yards", symbol: "yd", toBase: 0.9144),
        .init(name: "Miles", symbol: "mi", toBase: 1609.344)
    ]

    static let weightUnits: [ConversionUnit] = [
        .init(name: "Grams", symbol: "g", toBase: 0.001),
        .init(name: "Kilograms", symbol: "kg", toBase: 1),
        .init(name: "Tonnes", symbol: "t", toBase: 1000),
        .init(name: "Ounces", symbol: "oz", toBase: 0.028349523125),
        .init(name: "Pounds", symbol: "lb", toBase: 0.45359237),
        .init(name: "Stone", symbol: "st", toBase: 6.35029318)
    ]

    static let temperatureUnits: [ConversionUnit] = [
        .init(name: "Celsius", symbol: "°C", toBase: 1),
        .init(name: "Fahrenheit", symbol: "°F", toBase: 1),
        .init(name: "Kelvin", symbol: "K", toBase: 1)
    ]

    static let volumeUnits: [ConversionUnit] = [
        .init(name: "Millilitres", symbol: "mL", toBase: 0.001),
        .init(name: "Litres", symbol: "L", toBase: 1),
        .init(name: "Cubic metres", symbol: "m³", toBase: 1000),
        .init(name: "Teaspoons (US)", symbol: "tsp", toBase: 0.00492892159375),
        .init(name: "Tablespoons (US)", symbol: "tbsp", toBase: 0.01478676478125),
        .init(name: "Fluid ounces (US)", symbol: "fl oz", toBase: 0.0295735295625),
        .init(name: "Cups (US)", symbol: "cup", toBase: 0.2365882365),
        .init(name: "Pints (US)", symbol: "pt", toBase: 0.473176473),
        .init(name: "Gallons (US)", symbol: "gal", toBase: 3.785411784)
    ]

    static let speedUnits: [ConversionUnit] = [
        .init(name: "Metres / second", symbol: "m/s", toBase: 1),
        .init(name: "Kilometres / hour", symbol: "km/h", toBase: 0.277777778),
        .init(name: "Miles / hour", symbol: "mph", toBase: 0.44704),
        .init(name: "Knots", symbol: "kn", toBase: 0.514444444)
    ]

    static let dataUnits: [ConversionUnit] = [
        .init(name: "Bytes", symbol: "B", toBase: 1),
        .init(name: "Kilobytes", symbol: "KB", toBase: 1000),
        .init(name: "Megabytes", symbol: "MB", toBase: 1_000_000),
        .init(name: "Gigabytes", symbol: "GB", toBase: 1_000_000_000),
        .init(name: "Terabytes", symbol: "TB", toBase: 1_000_000_000_000)
    ]

    /// Offline snapshot, units per 1 USD, October 2026 — approximate, not live.
    static let currencyUnits: [ConversionUnit] = [
        .init(name: "US Dollar", symbol: "USD", toBase: 1),
        .init(name: "Euro", symbol: "EUR", toBase: 0.92),
        .init(name: "British Pound", symbol: "GBP", toBase: 0.79),
        .init(name: "Canadian Dollar", symbol: "CAD", toBase: 1.36),
        .init(name: "Australian Dollar", symbol: "AUD", toBase: 1.52),
        .init(name: "Japanese Yen", symbol: "JPY", toBase: 149.5),
        .init(name: "Swiss Franc", symbol: "CHF", toBase: 0.88),
        .init(name: "Chinese Yuan", symbol: "CNY", toBase: 7.24),
        .init(name: "Indian Rupee", symbol: "INR", toBase: 83.9),
        .init(name: "Mexican Peso", symbol: "MXN", toBase: 17.1)
    ]

    static func convert(_ value: Double, from: ConversionUnit, to: ConversionUnit, category: ConversionCategory) -> Double {
        if category == .temperature {
            let celsius: Double
            switch from.symbol {
            case "°F": celsius = (value - 32) * 5 / 9
            case "K": celsius = value - 273.15
            default: celsius = value
            }
            switch to.symbol {
            case "°F": return celsius * 9 / 5 + 32
            case "K": return celsius + 273.15
            default: return celsius
            }
        }
        if category == .currency {
            // toBase is units per USD: amount / rate(from) gives USD.
            return value / from.toBase * to.toBase
        }
        return value * from.toBase / to.toBase
    }
}

// MARK: - Converter view

struct ConverterView: View {
    @AppStorage("accentHex") private var accentHex = AccentTheme.defaultHex
    @State private var category: ConversionCategory = .length
    @State private var fromUnit: ConversionUnit = ConversionUnit.lengthUnits[2]
    @State private var toUnit: ConversionUnit = ConversionUnit.lengthUnits[5]
    @State private var input = "1"

    private var result: Double? {
        // Accept comma decimals ("3,5") as well as "3.5" (Claude review fix).
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return ConversionUnit.convert(value, from: fromUnit, to: toUnit, category: category)
    }

    var body: some View {
        Form {
            Section {
                Picker("Category", selection: $category) {
                    ForEach(ConversionCategory.allCases) { c in
                        Text(c.label).tag(c)
                    }
                }
                .onChange(of: category) { _, new in
                    let (fromIndex, toIndex) = Self.defaultUnitIndexes(for: new)
                    fromUnit = new.units[fromIndex]
                    toUnit = new.units[toIndex]
                }
            }

            Section("From") {
                Picker("Unit", selection: $fromUnit) {
                    ForEach(category.units) { u in
                        Text("\(u.name) (\(u.symbol))").tag(u)
                    }
                }
                TextField("Value", text: $input)
                    .keyboardType(.decimalPad)
                    .font(.title3)
            }

            Section {
                Button {
                    swap(&fromUnit, &toUnit)
                } label: {
                    Label("Swap Units", systemImage: "arrow.up.arrow.down")
                }
            }

            Section("To") {
                Picker("Unit", selection: $toUnit) {
                    ForEach(category.units) { u in
                        Text("\(u.name) (\(u.symbol))").tag(u)
                    }
                }
                if let result {
                    Text("\(formatted(result)) \(toUnit.symbol)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color(hex: accentHex))
                } else {
                    Text("Enter a value above")
                        .foregroundStyle(.secondary)
                }
            }

            if category == .currency {
                Section {
                    Text("Currency rates are an offline snapshot from October 2026 (units per 1 USD) and are approximate — not live exchange rates.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private static func defaultUnitIndexes(for category: ConversionCategory) -> (Int, Int) {
        switch category {
        case .length: return (2, 5)      // m -> ft
        case .weight: return (1, 4)      // kg -> lb
        case .temperature: return (0, 1) // °C -> °F
        case .volume: return (1, 8)      // L -> gal
        case .speed: return (1, 2)       // km/h -> mph
        case .data: return (2, 3)        // MB -> GB
        case .currency: return (0, 1)    // USD -> EUR
        }
    }

    private func formatted(_ value: Double) -> String {
        let magnitude = abs(value)
        if value != 0 && (magnitude >= 1e12 || magnitude < 1e-6) {
            return value.formatted(.number.notation(.scientific).precision(.significantDigits(1...6)))
        }
        return value.formatted(.number.precision(.significantDigits(1...10)).grouping(.automatic))
    }
}
