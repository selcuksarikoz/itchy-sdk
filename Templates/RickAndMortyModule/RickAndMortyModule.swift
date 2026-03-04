import AppKit
import SwiftUI
import itchy

@objc(RickAndMortyModulePlugin)
final class RickAndMortyModulePlugin: NSObject, ItchyModulePlugin {
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.rickandmorty",
            displayName: "Rick & Morty",
            summary: "Browse Rick and Morty characters from the API",
            preferredWidth: 612,
            placement: .menuApp,
            iconSystemName: "star.fill"
        )
    }

    func makeViewController() -> NSViewController {
        NSHostingController(rootView: RickAndMortyModuleView())
    }
}
