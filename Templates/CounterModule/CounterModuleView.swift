import SwiftUI
import itchy

/// An interactive SwiftUI view for the Counter module.
/// Demonstrates how standard SwiftUI @State works within a Nook module.
struct CounterModuleView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("\(count)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                Button(action: { count -= 1 }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)

                Button(action: { count += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            
            /// Standard alignment helper: ensures the module content is top-aligned.
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        /// Essential extension to align correctly within the Nook strip.
        .nookModuleLayout()
    }
}
