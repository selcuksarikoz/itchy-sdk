import SwiftUI
import itchy

/// A full-width view for a standalone menu application.
/// Shows how to create a scrollable grid of cards within the Notch.
struct MiniShelfModuleView: View {
    private let items = [
        ("Project Alpha", "circle.fill", Color.blue),
        ("Beta Review", "square.fill", Color.green),
        ("Gamma Release", "triangle.fill", Color.orange),
        ("Delta Sprint", "diamond.fill", Color.purple),
        ("Epsilon Testing", "star.fill", Color.yellow),
        ("Zeta Deployment", "pentagon.fill", Color.red)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(items, id: \.0) { item in
                    ShelfCard(title: item.0, icon: item.1, color: item.2)
                }
                
                /// Standard alignment helper: ensures content doesn't get cut off at the bottom.
                Spacer(minLength: 20)
            }
            .padding(.top, 4)
        }
    }
}

/// A simple card representation within the Mini Shelf.
private struct ShelfCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
