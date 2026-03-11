import AppKit
import SwiftUI
import itchy

@objc(IPTVModulePlugin)
final class IPTVModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.iptv",
            displayName: "IPTV",
            summary: "Open an IPTV panel with playlist URL input, channel list, and live player",
            preferredWidth: 220,
            placement: .nookModule,
            iconSystemName: "tv"
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: IPTVModuleView())
    }
}
