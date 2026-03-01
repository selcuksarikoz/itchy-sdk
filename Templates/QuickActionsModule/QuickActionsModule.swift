import AppKit
import SwiftUI
import itchy

@objc(QuickActionsModulePlugin)
final class QuickActionsModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.quickactions",
            displayName: "Quick Actions",
            summary: "Three tappable shortcuts inside the Nook",
            preferredWidth: 260
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: QuickActionsModuleView())
    }
}
