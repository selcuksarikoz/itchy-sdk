import AppKit
import SwiftUI
import itchy

/// The Principal Class for the Counter Module.
/// This module demonstrates an interactive Nook tile.
@objc(CounterModulePlugin)
final class CounterModulePlugin: NSObject, ItchyModulePlugin {
    
    /// Metadata configuration for the counter.
    /// `placement: .nookModule` keeps it in the horizontal strip.
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.counter",
            displayName: "Counter",
            summary: "A simple interactive counter for the Nook area",
            preferredWidth: 200,
            placement: .nookModule,
            iconSystemName: "plusminus.circle"
        )
    }

    /// Provides the interactive view hosted in an NSHostingController.
    func makeViewController() -> NSViewController {
        NSHostingController(rootView: CounterModuleView())
    }
}
