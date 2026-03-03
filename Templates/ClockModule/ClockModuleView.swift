import SwiftUI
import itchy

/// The primary view displayed in the Nook area for the Clock module.
/// This view showcases multiple time zones in a vertical scrollable list.
struct ClockModuleView: View {
    private let timeZones = [
        ("Local", TimeZone.current),
        ("NYC", TimeZone(identifier: "America/New_York")!),
        ("London", TimeZone(identifier: "Europe/London")!),
        ("Paris", TimeZone(identifier: "Europe/Paris")!),
        ("Tokyo", TimeZone(identifier: "Asia/Tokyo")!),
        ("Sydney", TimeZone(identifier: "Australia/Sydney")!),
        ("Dubai", TimeZone(identifier: "Asia/Dubai")!),
        ("Singapore", TimeZone(identifier: "Asia/Singapore")!),
        ("LA", TimeZone(identifier: "America/Los_Angeles")!),
        ("Berlin", TimeZone(identifier: "Europe/Berlin")!)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(timeZones, id: \.0) { zone in
                    TimeZoneRow(name: zone.0, timeZone: zone.1)
                }
                
                /// Standard alignment helper: ensures top alignment even with short content.
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        /// Mandatory extension to ensure the view aligns correctly within the Nook strip.
        .nookModuleLayout()
    }
}

/// A single row representing a specific time zone.
private struct TimeZoneRow: View {
    let name: String
    let timeZone: TimeZone

    var body: some View {
        /// TimelineView ensures the time updates every second automatically.
        TimelineView(.periodic(from: .now, by: 1)) { context in
            HStack {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Text(context.date.formatted(date: .omitted, time: .standard))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
