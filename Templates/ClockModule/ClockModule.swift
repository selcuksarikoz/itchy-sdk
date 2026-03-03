import AppKit
import SwiftUI
import itchy

/// The Principal Class of the Clock Module.
/// This class handles metadata, view controller creation, and Live Activity triggering.
@objc(ClockModulePlugin)
final class ClockModulePlugin: NSObject, ItchyModulePlugin {
    
    /// Defines the module's identity. 
    /// `supportsLiveActivity: true` allows the module to show content in the collapsed Notch.
    var metadata: ItchyModuleMetadata {
        ItchyModuleMetadata(
            identifier: "com.example.clock",
            displayName: "Clock",
            summary: "A simple custom clock module showing world times",
            preferredWidth: 220,
            placement: .nookModule,
            iconSystemName: "clock",
            supportsLiveActivity: true
        )
    }

    /// Returns the primary view for the Nook tile.
    func makeViewController() -> NSViewController {
        NSHostingController(rootView: ClockModuleView())
    }

    /// Returns the compact view for the collapsed Notch (Live Activity).
    @objc func makeLiveActivityViewController() -> NSViewController {
        NSHostingController(rootView: ClockLiveActivityView())
    }

    private var timer: Timer?

    override init() {
        super.init()
        
        /// Example: Triggering a high-priority Live Activity notification every 5 seconds.
        /// This demonstrates how modules can 'pop up' information to the user.
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            /// The `trigger` method sends data to Itchy to display a temporary notification.
            ItchyLiveActivityTrigger.trigger(
                identifier: self.metadata.identifier,
                title: "Clock Update",
                message: "Local time check",
                trailingMessage: Date().formatted(date: .omitted, time: .shortened),
                systemIcon: "clock.fill",
                duration: 2.5
            )
        }
    }
}

/// A compact view designed to fit within the collapsed Notch height (~32pt).
struct ClockLiveActivityView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text(context.date.formatted(date: .omitted, time: .standard))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
    }
}
