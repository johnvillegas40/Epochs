import SwiftUI

public struct DeckBuilderView: View {
    @ObservedObject var collection: CollectionService
    @State private var selectedDeckIndex: Int = 0

    private let minimumDeckSize = 60
    private let maxCopiesPerCard = 4
    
    public init(collection: CollectionService) { self.collection = collection }
    
    public var body: some View {
        let deck = collection.decks[selectedDeckIndex]
        return VStack {
            HStack {
                Picker("Deck", selection: $selectedDeckIndex) {
                    ForEach(collection.decks.indices, id: \.self) { i in
                        Text(collection.decks[i].name).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                Spacer()
                Button("New Deck") {
                    let new = PlayerDeck(name: "Deck \(collection.decks.count + 1)", cardIDs: [])
                    collection.decks.append(new)
                    selectedDeckIndex = collection.decks.count - 1
                }
            }.padding()
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading) {
                    Text("All Cards").font(.headline)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 8) {
                            ForEach(collection.allCards, id: \.self) { c in
                                CardView(card: c)
                                    .onTapGesture {
                                        let count = collection.decks[selectedDeckIndex].cardIDs.filter { $0 == c.id }.count
                                        if count < maxCopiesPerCard {
                                            collection.decks[selectedDeckIndex].cardIDs.append(c.id)
                                        }
                                    }
                            }
                        }.padding(.vertical, 8)
                    }
                }.frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Deck: \(deck.name)")
                            .font(.headline)
                        Spacer()
                        Text(deck.cardIDs.count >= minimumDeckSize ? "Deck valid" : "Deck invalid")
                            .foregroundColor(deck.cardIDs.count >= minimumDeckSize ? .green : .red)
                    }
                    if deck.cardIDs.count < minimumDeckSize {
                        Text("Deck must contain at least \(minimumDeckSize) cards")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    ScrollView {
                        let deckCards = deck.cardIDs.compactMap { id in
                            collection.allCards.first(where: { $0.id == id })
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 8) {
                            ForEach(Array(deckCards.enumerated()), id: \.element) { idx, c in
                                CardView(card: c)
                                    .contextMenu {
                                        Button("Remove") {
                                            collection.decks[selectedDeckIndex].cardIDs.remove(at: idx)
                                        }
                                    }
                            }
                        }.padding(.vertical, 8)
                    }
                }.frame(maxWidth: .infinity)
            }.padding(.horizontal)
        }
    }
}
