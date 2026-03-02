import SwiftUI
import itchy

struct MiniShelfModuleView: View {
    private let items: [(String, String)] = [
        ("doc.text", "Spec"),
        ("photo", "Mock"),
        ("waveform", "Audio"),
        ("film", "Clip")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items, id: \.1) { item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: item.0)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }

                        Text(item.1)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.72))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
        }
        .nookModuleLayout()
    }
}
