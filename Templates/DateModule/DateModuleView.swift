import SwiftUI
import itchy

struct DateModuleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(Date.now.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.72))

                Text(Date.now.formatted(.dateTime.month(.wide).day()))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .nookModuleLayout()
    }
}
