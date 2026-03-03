import AppKit
import SwiftUI
import itchy

/// The Principal Class for the Mini Shelf Module.
/// This module demonstrates a full "Menu App" placement.
@objc(MiniShelfModulePlugin)
final class MiniShelfModulePlugin: NSObject, ItchyModulePlugin {
    
    /// Metadata defining a full standalone app within the Notch.
    /// `placement: .menuApp` puts it in the expanded Notch's header.
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.minishelf",
            displayName: "Mini Shelf",
            summary: "A custom standalone application hosted inside the Notch header",
            preferredWidth: 260,
            placement: .menuApp,
            iconSystemName: "square.grid.2x2"
        )
    }

    /// Provides the main application view.
    func makeViewController() -> NSViewController {
        NSHostingController(rootView: MiniShelfModuleView())
    }
}
