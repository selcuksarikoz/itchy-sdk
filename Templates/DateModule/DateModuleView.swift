import SwiftUI

struct DateModuleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))

            Text(Date.now.formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.72))

            Text(Date.now.formatted(.dateTime.month(.wide).day()))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black)
    }
}
