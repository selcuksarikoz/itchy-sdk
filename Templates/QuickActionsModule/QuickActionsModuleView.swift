import SwiftUI
import itchy

struct QuickActionsModuleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                actionChip("Focus")
                actionChip("Mute")
                actionChip("Capture")
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .nookModuleLayout()
    }

    private func actionChip(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.12))
            .clipShape(Capsule())
    }
}
