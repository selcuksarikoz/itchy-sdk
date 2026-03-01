import AppKit
import Foundation

private extension NSObject {
    func itchyString(for selectorName: String) -> String? {
        let selector = NSSelectorFromString(selectorName)
        guard responds(to: selector),
              let value = perform(selector)?.takeUnretainedValue() as? String else {
            return nil
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func itchyNumber(for selectorName: String) -> NSNumber? {
        let selector = NSSelectorFromString(selectorName)
        guard responds(to: selector),
              let value = perform(selector)?.takeUnretainedValue() as? NSNumber else {
            return nil
        }
        return value
    }
}

enum ValidationError: LocalizedError {
    case missingBundle(String)
    case invalidBundle(String)
    case bundleLoadFailed(String)
    case missingPrincipalClass
    case missingMetadata
    case missingFactory
    case factoryReturnedInvalidType
    case invalidIdentifier
    case invalidDisplayName
    case invalidPreferredWidth
    case invalidPlacement
    case invalidIconSystemName

    var errorDescription: String? {
        switch self {
        case .missingBundle(let path):
            "Bundle not found at path: \(path)"
        case .invalidBundle(let path):
            "Path is not a valid macOS bundle: \(path)"
        case .bundleLoadFailed(let path):
            "Bundle could not be loaded: \(path)"
        case .missingPrincipalClass:
            "Bundle is missing NSPrincipalClass."
        case .missingMetadata:
            "Principal class does not expose metadata."
        case .missingFactory:
            "Principal class does not expose makeViewController()."
        case .factoryReturnedInvalidType:
            "makeViewController() did not return an NSViewController."
        case .invalidIdentifier:
            "metadata.identifier is missing or invalid."
        case .invalidDisplayName:
            "metadata.displayName is missing or invalid."
        case .invalidPreferredWidth:
            "metadata.preferredWidth must be >= 160."
        case .invalidPlacement:
            "metadata.placement must be either nook or menu."
        case .invalidIconSystemName:
            "metadata.iconSystemName is missing or invalid."
        }
    }
}

struct ValidationReport {
    let identifier: String
    let displayName: String
    let summary: String
    let preferredWidth: Double
    let placement: String
    let iconSystemName: String
    let principalClassName: String
}

@main
struct ItchyModuleValidatorCLI {
    static func main() {
        do {
            let bundlePath = try parseBundlePath()
            let report = try validateBundle(at: bundlePath)
            print("Valid Itchy module bundle")
            print("Identifier: \(report.identifier)")
            print("Display Name: \(report.displayName)")
            print("Summary: \(report.summary.isEmpty ? "-" : report.summary)")
            print("Preferred Width: \(Int(report.preferredWidth))")
            print("Placement: \(report.placement)")
            print("Icon: \(report.iconSystemName)")
            print("Principal Class: \(report.principalClassName)")
            Foundation.exit(EXIT_SUCCESS)
        } catch {
            fputs("Validation failed: \(error.localizedDescription)\n", stderr)
            Foundation.exit(EXIT_FAILURE)
        }
    }

    private static func parseBundlePath() throws -> String {
        let args = CommandLine.arguments
        guard args.count == 2 else {
            throw ValidationError.missingBundle("Usage: swift run itchy-module-validator /path/to/MyModule.bundle")
        }
        return args[1]
    }

    private static func validateBundle(at path: String) throws -> ValidationReport {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ValidationError.missingBundle(path)
        }
        guard let bundle = Bundle(url: url) else {
            throw ValidationError.invalidBundle(path)
        }

        do {
            try bundle.loadAndReturnError()
        } catch {
            throw ValidationError.bundleLoadFailed(path)
        }

        guard let principalClass = bundle.principalClass as? NSObject.Type else {
            throw ValidationError.missingPrincipalClass
        }

        let instance = principalClass.init()
        let metadataSelector = NSSelectorFromString("metadata")
        let factorySelector = NSSelectorFromString("makeViewController")

        guard instance.responds(to: metadataSelector),
              let metadata = instance.perform(metadataSelector)?.takeUnretainedValue() as? NSObject else {
            throw ValidationError.missingMetadata
        }

        guard instance.responds(to: factorySelector) else {
            throw ValidationError.missingFactory
        }

        guard instance.perform(factorySelector)?.takeUnretainedValue() is NSViewController else {
            throw ValidationError.factoryReturnedInvalidType
        }

        let identifier = metadata.itchyString(for: "identifier") ?? ""
        let displayName = metadata.itchyString(for: "displayName") ?? ""
        let summary = metadata.itchyString(for: "summary") ?? ""
        let preferredWidth = metadata.itchyNumber(for: "preferredWidth")?.doubleValue ?? 0
        let placement = metadata.itchyString(for: "placementRawValue") ?? ""
        let iconSystemName = metadata.itchyString(for: "iconSystemName") ?? ""

        guard !identifier.isEmpty else { throw ValidationError.invalidIdentifier }
        guard !displayName.isEmpty else { throw ValidationError.invalidDisplayName }
        guard placement == "nook" || placement == "menu" else { throw ValidationError.invalidPlacement }
        guard !iconSystemName.isEmpty else { throw ValidationError.invalidIconSystemName }
        guard preferredWidth >= 160 else { throw ValidationError.invalidPreferredWidth }

        return ValidationReport(
            identifier: identifier,
            displayName: displayName,
            summary: summary,
            preferredWidth: preferredWidth,
            placement: placement,
            iconSystemName: iconSystemName,
            principalClassName: NSStringFromClass(principalClass)
        )
    }
}
