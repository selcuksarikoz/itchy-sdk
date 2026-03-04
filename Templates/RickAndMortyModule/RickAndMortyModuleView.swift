import AppKit
import SwiftUI
import itchy

// MARK: - Data Models

struct RickAndMortyCharacter: Identifiable, Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let image: String
    let location: Location

    struct Location: Codable {
        let name: String
    }
}

struct RickAndMortyResponse: Codable {
    let results: [RickAndMortyCharacter]
}

// MARK: - ViewModel

@MainActor
final class RickAndMortyViewModel: ObservableObject {
    @Published var characters: [RickAndMortyCharacter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCharacters() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let url = URL(string: "https://rickandmortyapi.com/api/character")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(RickAndMortyResponse.self, from: data)
            characters = response.results
        } catch {
            errorMessage = "Failed to load characters"
        }

        isLoading = false
    }
}

// MARK: - View

struct RickAndMortyModuleView: View {
    @StateObject private var viewModel = RickAndMortyViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                    Spacer()
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            } else if viewModel.characters.isEmpty {
                Text("Loading characters...")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.characters) { character in
                            CharacterRow(character: character)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await viewModel.fetchCharacters()
        }
    }
}

// MARK: - Character Row

private struct CharacterRow: View {
    let character: RickAndMortyCharacter

    var statusColor: Color {
        switch character.status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            // Async Image with caching
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.5)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text("\(character.status) - \(character.species)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text(character.location.name)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("RickAndMortyModuleView") {
    RickAndMortyModuleView()
        .frame(width: 280, height: 400)
        .padding(8)
        .background(Color.black)
}
