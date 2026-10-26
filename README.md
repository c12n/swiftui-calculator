# SwiftUI Calculator

A clean, modern calculator app for iPhone and iPad, built entirely with **SwiftUI** for **iOS 17+**, with a native **Liquid Glass** interface on iOS 26, native **Light / Dark Mode**, and a custom app icon.

Generated with the help of Claude (via claude.ai), then packaged as a standard Xcode project, published under the MIT License, and built into an unsigned IPA by GitHub Actions on a macOS runner.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-black)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- iOS-style calculator UI that adapts to any screen size
- **Native Liquid Glass on iOS 26+** — keys and the display use SwiftUI's native `glassEffect` (regular, tinted, interactive) grouped in a `GlassEffectContainer`, refracting the backdrop as you tap
- **Graceful fallback on iOS 17-25** — the same keys use adaptive material / solid fills, so the app still runs on iOS 17
- **Native Light / Dark Mode** — no forced colour scheme; the app follows the system Appearance setting, with light and dark previews, adaptive key colours, display and backdrop in both modes
- **Custom app icon** — a 1024×1024 calculator icon with dedicated Dark and Tinted appearance variants for iOS 18+/26 home screens
- Digits `0-9` and decimal point, with a 9-digit entry limit
- Operations: add `+`, subtract `−`, multiply `×`, divide `÷`
- Chained operations evaluated left-to-right — e.g. `2 + 3 × 4 = 20`
- Tapping a second operator before entering a number replaces the first
- Repeated `=` repeats the last operation
- Percent `%` with iOS-style behaviour — e.g. `50 + 10% = 55`
- Sign toggle `+/-`
- `C` clears the current entry, `AC` resets everything
- Divide-by-zero and overflow show `Error` — the next digit or `AC` recovers
- Active operator is highlighted, just like the Apple Calculator
- Large results switch to scientific notation automatically

## Screenshots

Open the project in Xcode and run it in an iPhone or iPad simulator to see the app. In Dark Mode it is the classic look — dark backdrop, translucent glass keys and orange operation keys. In Light Mode the backdrop, display and keys all invert natively. On iOS 26 the keys and display are Liquid Glass; on earlier versions they fall back to clean adaptive fills.

## Requirements

- iOS 17.0 or later (Liquid Glass requires iOS 26.0 or later)
- Xcode 26 or later to build the Liquid Glass code paths (Xcode 15/16 cannot compile the iOS 26 glass APIs used here); the GitHub Actions workflow uses a `macos-26` runner for this reason
- Swift 5.0
- No third-party dependencies

## Project Structure

```
swiftui-calculator/
├── Calculator.xcodeproj/                 # Xcode project + shared Calculator scheme
├── Calculator/
│   ├── CalculatorApp.swift               # @main app entry point, follows system appearance
│   ├── ContentView.swift                 # Display + button grid layout
│   ├── CalculatorViewModel.swift         # All calculator logic (@Observable)
│   ├── CalculatorButton.swift            # Reusable Liquid Glass round / capsule key view
│   └── Assets.xcassets/                  # App icon (incl. Dark + Tinted variants) + accent colour
├── .github/workflows/
│   └── build-ipa.yml                     # GitHub Actions: builds an unsigned IPA on macOS
├── LICENSE                               # MIT License
└── README.md
```

### How the code is organised

- **CalculatorApp.swift** — the `@main` entry point. Shows `ContentView` in a `WindowGroup` with no forced colour scheme, so Light / Dark Mode is entirely system-driven.
- **ContentView.swift** — lays out the display and a 5-row key grid with `GeometryReader`, so button size fits both width and height on iPhone and iPad. The `0` key spans two columns.
- **CalculatorViewModel.swift** — the logic, with no UI code. It defines `CalculatorOperation` and `CalculatorKey`, and an `@Observable` view model that tracks the current value, stored value, pending / last operation, entry state, and error state, and formats results.
- **CalculatorButton.swift** — a reusable key view. It renders text or an SF Symbol, colours itself by kind (digit / function / operation) using the current colour scheme, inverts when its operation is active, and on iOS 26 renders with native Liquid Glass (`.glassEffect(.regular.tint(...).interactive(), in: Capsule())`); earlier iOS versions get an adaptive solid capsule. `ContentView` groups the keys in a `GlassEffectContainer` on iOS 26 and puts the display behind a glass / material panel, over a Light/Dark-adaptive gradient backdrop.

## Getting Started

### Run in Xcode

1. Clone the repo:

   ```bash
   git clone https://github.com/c12n/swiftui-calculator.git
   cd swiftui-calculator
   ```

2. Open the project:

   ```bash
   open Calculator.xcodeproj
   ```

3. Select an iPhone simulator (iOS 17+) or a connected device, then Run (`Cmd+R`).

To run on a physical device, select your own Development Team in **Signing & Capabilities** for the `Calculator` target — Apple requires a team to sign apps for devices.

### Build an IPA locally (Mac only)

On a Mac with Xcode:

```bash
xcodebuild \
  -project Calculator.xcodeproj \
  -scheme Calculator \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/Calculator.xcarchive \
  archive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" DEVELOPMENT_TEAM=""

mkdir -p Payload
cp -R build/Calculator.xcarchive/Products/Applications/Calculator.app Payload/
zip -r Calculator.ipa Payload
```

This produces an **unsigned** `Calculator.ipa`.

### Build an IPA with GitHub Actions

Every push to `main` — and any manual run from the **Actions** tab (`Build IPA` → `Run workflow`) — builds the app on a `macos-26` runner (Xcode 26 / iOS 26 SDK, needed for Liquid Glass) and uploads the result as a workflow artifact named **`Calculator-IPA`**. Open the completed run in the Actions tab and download it from **Artifacts**.

## Installing the IPA

The IPA produced by this project is **unsigned**, because no Apple Developer certificate is included in the repo.

- It will **not** install on a stock iPhone by simply tapping / AirDropping it.
- To use it on your own device, re-sign it with your own certificate — for example by opening the project in Xcode and running it on your device, using Xcode to install a build, or using a re-signing / sideloading tool with your Apple ID.
- Signing, provisioning, and App Store distribution require an Apple Developer account and your own certificates, which are intentionally not stored in this repository.

## Usage

Tap keys as you would on a normal calculator:

| Key | Action |
| --- | --- |
| `0`–`9`, `.` | Enter a number |
| `+`, `−`, `×`, `÷` | Choose an operation (chains left-to-right) |
| `=` | Evaluate; tap again to repeat the last operation |
| `%` | Percent (iOS-style in `+` / `−` expressions) |
| `+/-` | Toggle sign |
| `C` | Clear current entry |
| `AC` | All clear — reset everything |

## Contributing

Issues and pull requests are welcome.

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-change`
3. Commit your changes: `git commit -m "Add my change"`
4. Push: `git push origin feature/my-change`
5. Open a pull request

Please keep the app dependency-free and compatible with iOS 17+.

## Credits

The original calculator logic and layout were generated with **Claude** via [claude.ai](https://claude.ai) (chat: "SwiftUI calculator app"), then organised into this Xcode project. The Liquid Glass interface, native Light / Dark Mode support and custom app icon were added afterwards, and the project was documented and set up with CI.

## License

MIT — see [LICENSE](LICENSE) for the full text.

Copyright (c) 2026 Youssef
