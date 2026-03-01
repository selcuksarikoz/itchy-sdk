# ClockModule Example

This folder is a reference example for a custom Itchy Nook module.

It uses:

- `placement: .nookModule`
- a compact SwiftUI view
- a bundle principal class that conforms to `ItchyModulePlugin`

## Files

- `ClockModule.swift`
  Principal plugin entry point. This is where `metadata` and `makeViewController()` live.
- `ClockModuleView.swift`
  SwiftUI content for the module.
- `Info.plist`
  Bundle metadata. `NSPrincipalClass` must match the plugin class name.

This example shows:

- the minimum plugin entry point shape
- metadata setup
- a compact SwiftUI module view
- the expected bundle structure

It is not meant to be used as a rigid copy-paste template.

## If you adapt this example

1. Rename the files and symbols from `ClockModule` to your module name.
2. Change `identifier` to your own reverse-DNS value.
3. Change `displayName`, `summary`, and `iconSystemName`.
4. Adjust `preferredWidth` for the width you want in the Nook strip.
5. Replace `ClockModuleView` with your own SwiftUI UI.

## Important code bits

`ClockModulePlugin` is the class Itchy loads from the compiled bundle.

`metadata.placement` is set to `.nookModule`, which means:

- the plugin appears in the Nook area
- `preferredWidth` affects layout directly
- this is not a full Nook app tab

If you want a full Nook app instead, adapt the same structure but change:

```swift
placement: .menuApp
```

That will make the plugin behave as a Nook app in the expanded app area.

## Xcode setup

Create a macOS Bundle target and:

1. Add the `ItchySDK` package.
2. Copy these source files into the target.
3. Set `NSPrincipalClass` in `Info.plist` to `ClockModulePlugin`.
4. Make sure the target builds a `.bundle`, not an app.
5. Build the target.
6. Import the compiled bundle from Itchy Settings.

## Result

The compiled output should look like:

```text
YourModule.bundle/
  Contents/
    Info.plist
    MacOS/
      YourModule
```

That compiled `.bundle` is what Itchy imports.
