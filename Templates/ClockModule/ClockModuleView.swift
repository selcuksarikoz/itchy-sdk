import SwiftUI
import itchy

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
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .nookModuleLayout()
    }
}

private struct TimeZoneRow: View {
    let name: String
    let timeZone: TimeZone

    var body: some View {
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
