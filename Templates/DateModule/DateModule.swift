import AppKit
import SwiftUI
import itchy

/// The Principal Class for the Date Module.
/// This module provides a simple, informative tile for the Nook.
@objc(DateModulePlugin)
final class DateModulePlugin: NSObject, ItchyModulePlugin {
    
    /// Metadata defining the module's presence.
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.date",
            displayName: "Date",
            summary: "A simple, clean date display for the Nook area",
            preferredWidth: 240,
            placement: .nookModule,
            iconSystemName: "calendar"
        )
    }

    /// Hosts the DateModuleView in an NSHostingController.
    func makeViewController() -> NSViewController {
        NSHostingController(rootView: DateModuleView())
    }
}
