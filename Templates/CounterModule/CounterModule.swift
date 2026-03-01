import AppKit
import SwiftUI
import itchy

@objc(CounterModulePlugin)
final class CounterModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.counter",
            displayName: "Counter",
            summary: "An interactive counter module",
            preferredWidth: 220,
            placement: .nookModule,
            iconSystemName: "plusminus.circle"
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: CounterModuleView())
    }
}
