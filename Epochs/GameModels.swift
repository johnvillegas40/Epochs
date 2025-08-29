import Foundation

public struct PlayerDeck: Codable, Hashable {
    public var name: String
    public var cardIDs: [String]
}

public final class CollectionService: ObservableObject {
    @Published public var allCards: [Card] = []
    @Published public var decks: [PlayerDeck] = []
    
    public init(cards: [Card]) {
        self.allCards = cards
        self.decks = [PlayerDeck(name: "Starter Deck", cardIDs: cards.prefix(10).map { $0.id })]
    }
}