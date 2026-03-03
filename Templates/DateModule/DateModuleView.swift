import SwiftUI
import itchy

/// A clean, informative view for the Date module.
/// Demonstrates the use of standard SwiftUI Date formatting.
struct DateModuleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date().formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)

            Text(Date().formatted(.dateTime.day().month(.wide)))
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(.white)

            Text(Date().formatted(.dateTime.year()))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            /// Standard alignment helper: ensuring the content top-aligns within the Nook strip.
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        /// Mandatory layout extension for all Nook modules.
        .nookModuleLayout()
    }
}
