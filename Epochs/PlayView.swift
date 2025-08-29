import SwiftUI

public struct PlayView: View {
    let deck: PlayerDeck
    let allCards: [Card]
    @State private var hand: [Card] = []
    @State private var battlefield: [Card] = []
    @State private var library: [Card] = []
    @State private var ip: Int = 20
    
    public init(deck: PlayerDeck, allCards: [Card]) {
        self.deck = deck
        self.allCards = allCards
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Influence Points: \(ip)").font(.headline)
                Spacer()
                Button("Draw") { draw(1) }
                Button("Play First From Hand") {
                    if let first = hand.first {
                        battlefield.append(first); hand.removeFirst()
                    }
                }
                Button("Gain +1 IP") { ip += 1 }
                Button("Lose -1 IP") { ip = max(0, ip - 1) }
            }.padding(.horizontal)
            
            Text("Battlefield").font(.title3)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(battlefield, id: \.self) { c in CardView(card: c).frame(width: 220) }
                }.padding(.horizontal)
            }
            
            Divider()
            Text("Hand").font(.title3)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(hand, id: \.self) { c in CardView(card: c).frame(width: 220) }
                }.padding(.horizontal)
            }
        }
        .onAppear { reset() }
    }
    
    private func reset() {
        var deckCards: [Card] = deck.cardIDs.compactMap { id in allCards.first(where: { $0.id == id }) }
        deckCards.shuffle()
        library = deckCards
        hand = []
        battlefield = []
        ip = 20
        draw(7)
    }
    private func draw(_ n: Int) {
        for _ in 0..<n {
            if !library.isEmpty {
                hand.append(library.removeFirst())
            }
        }
    }
}