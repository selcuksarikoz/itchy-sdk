# ItchySDK

`ItchySDK` is the public plugin SDK for building custom Itchy Nook modules.

Repository:

- `https://github.com/selcuksarikoz/itchy-sdk`

## Install

Add the package from Xcode:

```text
https://github.com/selcuksarikoz/itchy-sdk
```

Then import:

```swift
import itchy
```

## What you build

Create a macOS `.bundle` target whose principal class conforms to `ItchyModulePlugin`.

`Templates/DateModule/` like folders are source examples only. They are not importable plugins.

The thing Itchy loads is the compiled output:

- `DateModule.bundle`
- `CounterModule.bundle`

You must explicitly choose one placement in code:

- `placement: .nookModule`
- `placement: .menuApp`

Itchy renders the Nook title from `metadata.displayName`. Your plugin view should usually render only the content area and keep its background transparent.

Your principal class must expose:

- `metadata`
- `makeViewController()`

## Output

Build your bundle, then import the compiled `.bundle` from:

- `Itchy > Settings > Modules > Custom Modules > Import Module`

Or copy it manually to:

- `~/Library/Application Support/Itchy/Modules`

After copying manually, reopen Itchy or reopen Settings so the module list refreshes.

## What is a `.bundle`?

A macOS `.bundle` is a package directory. In Finder it may look like a single file, but it is actually a folder with this structure:

```text
MyModule.bundle/
  Contents/
    Info.plist
    MacOS/
      MyModule
```

If Finder is hiding package contents, that is normal. Itchy expects the compiled `.bundle`, not the template source folder.

## Build from Terminal

Run these commands from the `ItchySDK` repository root.

Example: build the `DateModule` template into a real bundle inside `ItchySDK/BuiltBundles/`.

```bash
swift build

mkdir -p BuiltBundles/DateModule.bundle/Contents/MacOS \
  BuiltBundles/DateModule.bundle/Contents/Resources

cp Templates/DateModule/Info.plist \
  BuiltBundles/DateModule.bundle/Contents/Info.plist

swiftc -parse-as-library -emit-library -Xlinker -bundle \
  -module-name DateModule \
  -I .build/arm64-apple-macosx/debug/Modules \
  Templates/DateModule/DateModule.swift \
  Templates/DateModule/DateModuleView.swift \
  .build/arm64-apple-macosx/debug/itchy.build/ItchyModulePlugin.swift.o \
  -o BuiltBundles/DateModule.bundle/Contents/MacOS/DateModule
```

Then validate it:

```bash
swift run itchy-module-validator BuiltBundles/DateModule.bundle
```

The resulting bundle will be here:

- `ItchySDK/BuiltBundles/DateModule.bundle`

You can import that bundle directly into Itchy.

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
- `makeViewController()` returns an `NSViewController`
- identifier and display name are valid
- preferred width is sane

## Templates

Starter module templates live in `Templates/`:

- `ClockModule`
- `CounterModule`
- `DateModule`
- `MiniShelfModule`
- `QuickActionsModule`

Each template is a standalone example bundle entry point plus SwiftUI view.

## Local development

You can add this package locally in Xcode by selecting the `ItchySDK` folder.

## Distribution

When publishing, expose `ItchySDK` as a Swift package in your public repository so developers can add it directly from Xcode.
