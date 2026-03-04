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

Create a macOS `.bundle` target whose principal class conforms to `ItchyModulePlugin`. Itchy uses **NSViewController hosting** to display your SwiftUI views.

Your principal class must inherit from `NSObject` and be marked as the `NSPrincipalClass` in your `Info.plist`.

The public SDK surface is:

```swift
// Constants
public struct ItchyConstants {
    public static let moduleHeight: CGFloat = 120.0
}

// Placements
public enum ItchyPluginPlacement: String {
    case nookModule = "nook"
    case menuApp = "menu"
}

// Metadata
public final class ItchyModuleMetadata: NSObject {
    public init(
        identifier: String,
        displayName: String,
        summary: String = "",
        preferredWidth: NSNumber = 240,
        placement: ItchyPluginPlacement,
        iconSystemName: String = "square.grid.2x2",
        supportsLiveActivity: Bool = false
    )
}

// Plugin Protocol
public protocol ItchyModulePlugin: AnyObject {
    var metadata: ItchyModuleMetadata { get }
    func makeViewController() -> NSViewController
    
    // Lifecycle
    @objc optional func pluginDidLoad()
    
    // Live Activity Support (Optional)
    @objc optional func makeLiveActivityViewController() -> NSViewController
    @objc optional var isLiveActivityActive: Bool { get }
}
...
### Lifecycle
- `init()`: Standard initialization. Avoid firing one-time triggers here.
- `pluginDidLoad()`: Called when Itchy has fully loaded your bundle and is ready to handle events. Recommended for starting timers or sending initial notifications.

// Trigger Helper
public final class ItchyLiveActivityTrigger: NSObject {
    @objc public static func trigger(
        identifier: String, 
        title: String?, 
        message: String?, 
        trailingMessage: String?,
        systemIcon: String?, 
        duration: TimeInterval
    )
}
```

## API Reference

### Module Metadata (`ItchyModuleMetadata`)
| Property | Type | Description |
| :--- | :--- | :--- |
| `identifier` | `String` | Unique reverse-DNS ID (e.g., `com.user.mod`). |
| `displayName` | `String` | Human-readable name shown in settings/headers. |
| `summary` | `String` | Short description of the module. |
| `preferredWidth`| `NSNumber` | Initial width in the Nook (min 160pt). |
| `placement` | `Enum` | `.nookModule` (strip) or `.menuApp` (standalone). |
| `iconSystemName`| `String` | Header icon hint. SF Symbol is used if provided; otherwise Itchy falls back to the bundle icon when available. |
| `supportsLiveActivity` | `Bool` | Enable support for collapsed Notch views. |

### Plugin Protocol (`ItchyModulePlugin`)
| Method / Property | Requirement | Description |
| :--- | :--- | :--- |
| `metadata` | **Required** | Your module's configuration. |
| `makeViewController()` | **Required** | Returns the main SwiftUI-hosted view controller. |
| `pluginDidLoad()` | Optional | Called when Itchy is ready. Best for starting timers. |
| `makeLiveActivityViewController()` | Optional | Returns the compact view for the collapsed Notch. |
| `isLiveActivityActive` | Optional | Polled by Itchy to control persistent visibility. |

### Live Activity Trigger (`ItchyLiveActivityTrigger`)
| Parameter | Type | Description |
| :--- | :--- | :--- |
| `identifier` | `String` | The identifier of your module. |
| `title` | `String?` | Bold title shown on the left. |
| `message` | `String?` | Small descriptive text below the title. |
| `trailingMessage`| `String?` | **Bold monospaced** text on the far right. |
| `systemIcon` | `String?` | SF Symbol name for the icon. |
| `duration` | `TimeInterval`| How long to stay visible (highest priority). |

## Live Activities

Live Activities are compact views shown in the Notch when it is collapsed. They support two modes of operation:

### 1. Persistent (State-based) Mode
The view is shown based on your module's internal logic.

```swift
@objc(MyModule)
final class MyModule: NSObject, ItchyModulePlugin {
    // ... metadata ...

    // 1. Enable support
    // metadata.supportsLiveActivity = true

    // 2. Return your compact view
    @objc func makeLiveActivityViewController() -> NSViewController {
        NSHostingController(rootView: MyCompactView())
    }

    // 3. Control visibility (polled every second)
    @objc var isLiveActivityActive: Bool {
        return someInternalState == .active
    }
}
```

### 2. Triggered (Notification) Mode
Instantly show a high-priority notification. This overrides built-in activities (Music, Timer) for the specified duration.

```swift
// Option A: Using the protocol extension (easiest)
self.triggerLiveActivity(
    title: "Download",
    message: "File.zip",
    trailingMessage: "85%", // Appears on the far right
    systemIcon: "arrow.down.circle.fill",
    duration: 3.0
)

// Option B: Using the global trigger class
ItchyLiveActivityTrigger.trigger(
    identifier: "com.user.mod",
    title: "Alert",
    message: "Something happened",
    trailingMessage: "ERR",
    systemIcon: "exclamationmark.triangle",
    duration: 5.0
)
```

### Priority & Visibility Logic
Itchy manages visibility based on the following priority:
1. **Triggered Activities:** Temporary overrides from any module (highest).
2. **Built-in Activities:** Active Mail, Focus Timers, or Media Playback.
3. **Persistent Custom Activities:** Modules with `isLiveActivityActive: true`.

If multiple activities exist in the same tier, Itchy rotates them every 8 seconds.

### Design Guidelines
- **Height:** The live activity container is ~30-32pt high (Capsule shape).
- **Trailing Message:** Use `trailingMessage` for status, percentages, or short values (e.g., "12:45", "99%", "ON"). It is rendered with a bold monospaced font on the right.
- **Icons:** Use SF Symbols for `systemIcon`.

## Placement guide

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

Itchy automatically renders the module title from `metadata.displayName` where appropriate. Do not include a duplicate title in your SwiftUI view.

Your SwiftUI view should:

- render only its content (no title)
- use `.nookModuleLayout()` on its root container for consistent alignment
- use `Spacer(minLength: 0)` inside its `VStack` to ensure top alignment even if the content is short
- keep its background transparent
- use `ScrollView` if content may overflow
- access `ItchyConstants.moduleHeight` for the standard module height (120pt)

For Nook apps (`.menuApp`):

- Itchy renders the header tab for you
- your SwiftUI view should render only app content, not a duplicated title/header
- the header tab icon uses the bundle icon when available, with `iconSystemName` as fallback
- you can ship a custom PNG bundle icon via `CFBundleIconFile`; `RickAndMortyModule` demonstrates this with `Resources/RickAndMortyIcon.png`
- the app canvas can use the full available width; set `preferredWidth` accordingly if you want a full-width app

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

`Templates/...` folders are source examples only. The compiled outputs live in `BuiltBundles/...`.

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
    Resources/
      MyModuleIcon.png
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

cp -R Templates/DateModule/Resources/. \
  BuiltBundles/DateModule.bundle/Contents/Resources/

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
