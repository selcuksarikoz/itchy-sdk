import AppKit
import SwiftUI
import itchy

@objc(MiniShelfModulePlugin)
final class MiniShelfModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.minishelf",
            displayName: "Mini Shelf",
            summary: "A custom menu content plugin with small cards",
            preferredWidth: 260,
            placement: .menuApp,
            iconSystemName: "square.grid.2x2"
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: MiniShelfModuleView())
    }
}
