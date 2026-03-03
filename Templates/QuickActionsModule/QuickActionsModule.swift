import AppKit
import SwiftUI
import itchy

/// The Principal Class for the Quick Actions Module.
/// Demonstrates a standalone "Menu App" used for rapid system shortcuts.
@objc(QuickActionsModulePlugin)
final class QuickActionsModulePlugin: NSObject, ItchyModulePlugin {
    
    /// Metadata Defining the Quick Actions Application.
    /// `placement: .menuApp` creates a dedicated tab in the expanded Notch header.
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.quickactions",
            displayName: "Quick Actions",
            summary: "A standalone menu app for quick system shortcuts",
            preferredWidth: 260,
            placement: .menuApp,
            iconSystemName: "bolt.circle"
        )
    }

    /// Provides the application interface.
    func makeViewController() -> NSViewController {
        NSHostingController(rootView: QuickActionsModuleView())
    }
}
