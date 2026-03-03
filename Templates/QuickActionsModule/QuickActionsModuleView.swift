import SwiftUI
import itchy

/// A full-width view for a system shortcuts application.
/// Demonstrates using standard SwiftUI buttons to trigger system events.
struct QuickActionsModuleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("System Controls")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ActionButton(title: "Sleep", icon: "moon.fill", color: .indigo) {
                    print("Requesting System Sleep")
                }
                ActionButton(title: "Restart", icon: "arrow.clockwise", color: .orange) {
                    print("Requesting System Restart")
                }
                ActionButton(title: "Lock", icon: "lock.fill", color: .red) {
                    print("Requesting Screen Lock")
                }
            }
            
            /// Standard alignment helper: ensures the module content is top-aligned.
            Spacer(minLength: 0)
        }
    }
}

/// A standardized action button for the Quick Actions module.
private struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.15))
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
