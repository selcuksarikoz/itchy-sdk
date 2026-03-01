# ClockModule Template

This folder contains the minimum files for a custom Itchy module bundle:

- `ClockModule.swift`: principal plugin class
- `ClockModuleView.swift`: SwiftUI content
- `Info.plist`: bundle metadata

## Xcode target

Create a macOS Bundle target and:

1. Add the `ItchySDK` package.
2. Copy these source files into the target.
3. Set `NSPrincipalClass` to `ClockModulePlugin`.
4. Build the target to produce a `.bundle`.
5. Import the bundle from Itchy Settings.
