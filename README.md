# ItchySDK

`ItchySDK` is the public plugin SDK for building custom Itchy extensions.

Repository:

- `https://github.com/selcuksarikoz/itchy-sdk`

## What you can build

`ItchySDK` currently supports two plugin placements:

- `placement: .nookModule`
  Builds a Nook module that appears inside the horizontal Nook area.
- `placement: .menuApp`
  Builds a full-width Nook app that appears inside the expanded app area with its own tab button in the header.

If you say "Nook app" in docs or product copy, that maps to `placement: .menuApp` in code today.

Both plugin types are delivered as compiled macOS `.bundle` files.

## Install

Add the package from Xcode:

```text
https://github.com/selcuksarikoz/itchy-sdk
```

Then import:

```swift
import itchy
```

## Minimal plugin contract

Create a macOS `.bundle` target whose principal class conforms to `ItchyModulePlugin`.

Your principal class must expose:

- `metadata`
- `makeViewController()`

The public SDK surface is:

```swift
public enum ItchyPluginPlacement: String {
    case nookModule = "nook"
    case menuApp = "menu"
}

public struct ItchyConstants {
    public static let moduleHeight: CGFloat = 120.0
}

public final class ItchyModuleMetadata: NSObject {
    public init(
        identifier: String,
        displayName: String,
        summary: String = "",
        preferredWidth: NSNumber = 240,
        placement: ItchyPluginPlacement,
        iconSystemName: String = "square.grid.2x2"
    )
}

public protocol ItchyModulePlugin: AnyObject {
    var metadata: ItchyModuleMetadata { get }
    func makeViewController() -> NSViewController
}

extension View {
    public func nookModuleLayout() -> some View
}
```

## Placement guide

Choose `placement: .nookModule` when:

- your UI is compact
- your content belongs in the Nook strip
- `preferredWidth` should control module width directly

Choose `placement: .menuApp` when:

- you want a dedicated header tab
- your UI needs the expanded app canvas
- you are building a richer "mini app" instead of a single module tile

## UI expectations

Itchy automatically renders the module title from `metadata.displayName`. Do not include a title in your SwiftUI view.

Your SwiftUI view should:

- render only its content (no title)
- use `.nookModuleLayout()` on its root container for consistent alignment
- use `Spacer(minLength: 0)` inside its `VStack` to ensure top alignment even if the content is short
- keep its background transparent
- use `ScrollView` if content may overflow
- access `ItchyConstants.moduleHeight` for the standard module height (120pt)

For Nook apps (`.menuApp`), `iconSystemName` is used for the header tab button.

## Examples

Reference examples live in `Templates/`:

- `ClockModule`
- `CounterModule`
- `DateModule`
- `MiniShelfModule`
- `QuickActionsModule`

Example intent:

- `ClockModule`, `CounterModule`, `DateModule`
  Good starting points for compact Nook modules.
- `MiniShelfModule`, `QuickActionsModule`
  Good starting points for Nook apps using `placement: .menuApp`.

`Templates/...` folders are source examples only.

Important:

- they are not intended to be used as rigid copy-paste templates
- they are not directly importable by Itchy
- they are reference implementations showing plugin structure, metadata, placement, and SwiftUI composition

Itchy loads only the compiled `.bundle` output.

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

Itchy expects the compiled `.bundle`, not the template source folder.

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

You can import the resulting bundle directly into Itchy.

## Validate a bundle

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

## Recommended workflow

1. Inspect the closest example.
2. Decide whether you are building a Nook module or a Nook app.
3. Set `placement` correctly.
4. Keep the principal class tiny and move UI into SwiftUI views.
5. Build the `.bundle`.
6. Validate it with `itchy-module-validator`.
7. Import it into Itchy.

## Local development

You can add this package locally in Xcode by selecting the `ItchySDK` folder.

## Distribution

When publishing, expose `ItchySDK` as a Swift package in your public repository so developers can add it directly from Xcode.
