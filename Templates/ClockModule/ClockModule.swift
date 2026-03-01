import AppKit
import SwiftUI
import itchy

@objc(ClockModulePlugin)
final class ClockModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.clock",
            displayName: "Clock",
            summary: "A simple custom clock module",
            preferredWidth: 220
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: ClockModuleView())
    }
}
