import SwiftUI

public struct DeckBuilderView: View {
    @ObservedObject var collection: CollectionService
    @State private var selectedDeckIndex: Int = 0
    
    public init(collection: CollectionService) { self.collection = collection }
    
    public var body: some View {
        VStack {
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
                                        collection.decks[selectedDeckIndex].cardIDs.append(c.id)
                                    }
                            }
                        }.padding(.vertical, 8)
                    }
                }.frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    Text("Deck: \(collection.decks[selectedDeckIndex].name)")
                        .font(.headline)
                    ScrollView {
                        let deckCards = collection.decks[selectedDeckIndex].cardIDs.compactMap { id in
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