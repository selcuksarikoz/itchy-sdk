import AppKit
import SwiftUI
import itchy

@objc(DateModulePlugin)
final class DateModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.date",
            displayName: "Date",
            summary: "Shows today's date in the Nook",
            preferredWidth: 240
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: DateModuleView())
    }
}
