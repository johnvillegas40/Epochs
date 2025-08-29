import SwiftUI

struct ContentView: View {
    @State private var cards: [Card] = []
    @StateObject private var collection = CollectionService(cards: [])
    @State private var tab: Int = 0
    
    var body: some View {
        TabView(selection: $tab) {
            Group {
                if cards.isEmpty {
                    ProgressView("Loading cards…")
                } else {
                    CardGridView(cards: cards)
                }
            }
            .tabItem { Label("Cards", systemImage: "square.grid.2x2") }
            .tag(0)
            
            DeckBuilderView(collection: collection)
                .tabItem { Label("Deck Builder", systemImage: "rectangle.stack.badge.plus") }
                .tag(1)
            
            if let firstDeck = collection.decks.first {
                PlayView(deck: firstDeck, allCards: cards)
                    .tabItem { Label("Play (Sandbox)", systemImage: "gamecontroller") }
                    .tag(2)
            } else {
                Text("Create a deck in Deck Builder")
                    .tabItem { Label("Play (Sandbox)", systemImage: "gamecontroller") }
                    .tag(2)
            }
        }
        .task {
            do {
                if let url = Bundle.main.url(forResource: "CardDB", withExtension: "json") {
                    let loaded = try CardDB.load(from: url)
                    self.cards = loaded
                    self.collection.allCards = loaded
                    if self.collection.decks.isEmpty {
                        self.collection.decks = [PlayerDeck(name: "Starter Deck", cardIDs: loaded.prefix(10).map { $0.id })]
                    }
                }
            } catch {
                print("Failed to load CardDB.json: \(error)")
            }
        }
    }
}

@main
struct EpochsApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}