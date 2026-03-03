import AppKit
import SwiftUI

/// Notification name used to trigger a temporary Live Activity from a module.
public extension Notification.Name {
    static let itchyTriggerLiveActivity = Notification.Name("com.kuulto.itchy.triggerLiveActivity")
}

/// Data structure representing a temporary Live Activity notification.
/// This class is @objc compatible to ensure reliable cross-bundle communication.
@objc(ItchyLiveActivityNotification)
public final class ItchyLiveActivityNotification: NSObject {
    /// The unique identifier of the module triggering the activity.
    @objc public let identifier: String
    /// How long the activity should remain visible (in seconds).
    @objc public let duration: TimeInterval
    /// The main title shown in the Live Activity view.
    @objc public let title: String?
    /// The secondary descriptive message shown below the title.
    @objc public let message: String?
    /// A short status string shown on the far right (e.g., "99%", "ON", "12:00").
    @objc public let trailingMessage: String?
    /// SF Symbol name for the icon shown on the left.
    @objc public let systemIcon: String?

    @objc public init(identifier: String, duration: TimeInterval = 5.0, title: String? = nil, message: String? = nil, trailingMessage: String? = nil, systemIcon: String? = nil) {
        self.identifier = identifier
        self.duration = duration
        self.title = title
        self.message = message
        self.trailingMessage = trailingMessage
        self.systemIcon = systemIcon
        super.init()
    }
}

/// Defines where the module should be placed within the Itchy interface.
public enum ItchyPluginPlacement: String {
    /// Placed as a compact tile within the horizontal Nook strip.
    case nookModule = "nook"
    /// Placed as a full-width standalone application in the expanded Notch view.
    case menuApp = "menu"
}

/// Common constants for consistent module UI.
public struct ItchyConstants {
    /// The standard fixed height for Nook modules (120pt).
    public static let moduleHeight: CGFloat = 120.0
}

extension View {
    /// Applies the standard layout constraints for a Nook module.
    /// Ensures the content aligns correctly within the Nook container.
    public func nookModuleLayout() -> some View {
        self.frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Metadata describing the module's identity, appearance, and capabilities.
/// This must be provided by every Itchy plugin.
@objc(ItchyModuleMetadata)
@objcMembers
public final class ItchyModuleMetadata: NSObject {
    /// Unique reverse-DNS identifier (e.g., "com.example.mymodule").
    public let identifier: String
    /// Human-readable name shown in settings and headers.
    public let displayName: String
    /// A brief description of the module's purpose.
    public let summary: String
    /// Requested width for the module when placed in the Nook (min 160pt).
    public let preferredWidth: NSNumber
    /// Where the module should appear (nook or menu).
    public let placementRawValue: String
    /// SF Symbol name used for the module's icon.
    public let iconSystemName: String
    /// Whether the module provides a custom view for the collapsed Notch.
    public let supportsLiveActivity: Bool

    public init(
        identifier: String,
        displayName: String,
        summary: String = "",
        preferredWidth: NSNumber = 240,
        placement: ItchyPluginPlacement,
        iconSystemName: String = "square.grid.2x2",
        supportsLiveActivity: Bool = false
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.summary = summary
        self.preferredWidth = preferredWidth
        self.placementRawValue = placement.rawValue
        self.iconSystemName = iconSystemName
        self.supportsLiveActivity = supportsLiveActivity
    }

    /// Helper to access the placement as a typed enum.
    public var placement: ItchyPluginPlacement {
        ItchyPluginPlacement(rawValue: placementRawValue) ?? .nookModule
    }
}

/// The primary protocol that every Itchy custom module must conform to.
/// Your bundle's Principal Class must implement this protocol.
@objc(ItchyModulePlugin)
public protocol ItchyModulePlugin: AnyObject {
    /// The module's metadata configuration.
    var metadata: ItchyModuleMetadata { get }
    
    /// Returns the main view controller for the module.
    /// Itchy hosts this view inside the Nook or as a standalone app.
    func makeViewController() -> NSViewController
    
    /// Returns the view controller for the collapsed Notch (Live Activity).
    /// Only used if `metadata.supportsLiveActivity` is true.
    @objc optional func makeLiveActivityViewController() -> NSViewController
    
    /// Polled by Itchy to determine if the Persistent Live Activity should be shown.
    /// Return true to request visibility based on internal module state.
    @objc optional var isLiveActivityActive: Bool { get }
}

public extension ItchyModulePlugin {
    /// Convenience method to trigger a high-priority temporary Live Activity notification.
    /// - Parameters:
    ///   - title: Main title text.
    ///   - message: Secondary descriptive text.
    ///   - trailingMessage: Short status text shown on the right (e.g., "85%").
    ///   - systemIcon: SF Symbol name for the icon.
    ///   - duration: How long to show the notification (seconds).
    func triggerLiveActivity(title: String, message: String, trailingMessage: String? = nil, systemIcon: String = "bell.fill", duration: TimeInterval = 5.0) {
        ItchyLiveActivityTrigger.trigger(identifier: metadata.identifier, title: title, message: message, trailingMessage: trailingMessage, systemIcon: systemIcon, duration: duration)
    }
}

/// Global helper to trigger Live Activity notifications from anywhere.
@objc(ItchyLiveActivityTrigger)
public final class ItchyLiveActivityTrigger: NSObject {
    /// Posts a notification to Itchy to display a temporary Live Activity.
    @objc public static func trigger(identifier: String, title: String?, message: String?, trailingMessage: String?, systemIcon: String?, duration: TimeInterval) {
        let notification = ItchyLiveActivityNotification(
            identifier: identifier,
            duration: duration,
            title: title,
            message: message,
            trailingMessage: trailingMessage,
            systemIcon: systemIcon
        )
        NotificationCenter.default.post(name: .itchyTriggerLiveActivity, object: notification)
    }
}
