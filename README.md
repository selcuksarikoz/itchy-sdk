# ItchySDK

`ItchySDK` is the public plugin SDK for building custom Itchy Nook modules.

Repository:

- `https://github.com/selcuksarikoz/itchy-sdk`

## Import

```swift
import itchy
```

## What you build

Create a macOS `.bundle` target whose principal class conforms to `ItchyModulePlugin`.

Your principal class must expose:

- `metadata`
- `makeViewController()`

## Output

Build your bundle, then import the compiled `.bundle` from:

- `Itchy > Settings > Modules > Custom Modules > Import Module`

## Validate a module bundle

The SDK ships with a validator CLI:

```bash
swift run itchy-module-validator /path/to/MyModule.bundle
```

This checks:

- bundle exists
- principal class exists
- `metadata` exists
- `makeViewController()` exists
- identifier and display name are valid
- preferred width is sane

## Local development

You can add this package locally in Xcode by selecting the `ItchySDK` folder.

## Distribution

When publishing, expose `ItchySDK` as a Swift package in your public repository so developers can add it directly from Xcode.
