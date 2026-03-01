import AppKit

@objc(ItchyModuleMetadata)
@objcMembers
public final class ItchyModuleMetadata: NSObject {
    public let identifier: String
    public let displayName: String
    public let summary: String
    public let preferredWidth: NSNumber

    public init(
        identifier: String,
        displayName: String,
        summary: String = "",
        preferredWidth: NSNumber = 240
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.summary = summary
        self.preferredWidth = preferredWidth
    }
}

@objc(ItchyModulePlugin)
public protocol ItchyModulePlugin: AnyObject {
    var metadata: ItchyModuleMetadata { get }
    func makeViewController() -> NSViewController
}
