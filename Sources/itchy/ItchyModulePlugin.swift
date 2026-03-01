import AppKit

public enum ItchyPluginPlacement: String {
    case nookModule = "nook"
    case menuApp = "menu"
}

@objc(ItchyModuleMetadata)
@objcMembers
public final class ItchyModuleMetadata: NSObject {
    public let identifier: String
    public let displayName: String
    public let summary: String
    public let preferredWidth: NSNumber
    public let placementRawValue: String
    public let iconSystemName: String

    public init(
        identifier: String,
        displayName: String,
        summary: String = "",
        preferredWidth: NSNumber = 240,
        placement: ItchyPluginPlacement,
        iconSystemName: String = "square.grid.2x2"
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.summary = summary
        self.preferredWidth = preferredWidth
        self.placementRawValue = placement.rawValue
        self.iconSystemName = iconSystemName
    }

    public var placement: ItchyPluginPlacement {
        ItchyPluginPlacement(rawValue: placementRawValue) ?? .nookModule
    }
}

@objc(ItchyModulePlugin)
public protocol ItchyModulePlugin: AnyObject {
    var metadata: ItchyModuleMetadata { get }
    func makeViewController() -> NSViewController
}
