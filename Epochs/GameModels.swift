import Foundation

public struct PlayerDeck: Codable, Hashable {
    public var name: String
    public var cardIDs: [String]
}

public final class CollectionService: ObservableObject {
    @Published public var allCards: [Card] = []
    @Published public var decks: [PlayerDeck] = [] {
        didSet { saveDecks() }
    }

    private let fileManager = FileManager.default
    private var decksURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("decks.json")
    }

    public init(cards: [Card]) {
        self.allCards = cards
        if let saved = loadDecks() {
            self.decks = saved
        } else {
            self.decks = [PlayerDeck(name: "Starter Deck", cardIDs: cards.prefix(10).map { $0.id })]
            saveDecks()
        }
    }

    public func saveDecks() {
        do {
            let data = try JSONEncoder().encode(decks)
            try data.write(to: decksURL, options: .atomic)
        } catch {
            print("Failed to save decks: \(error)")
        }
    }

    public func loadDecks() -> [PlayerDeck]? {
        guard fileManager.fileExists(atPath: decksURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: decksURL)
            let decoded = try JSONDecoder().decode([PlayerDeck].self, from: data)
            return decoded
        } catch {
            print("Failed to load decks: \(error)")
            return nil
        }
    }
}
