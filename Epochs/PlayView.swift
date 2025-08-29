import SwiftUI

public struct PlayView: View {
    @StateObject private var engine: RulesEngine
    private let ai: AIPlayer

    public init(deck: PlayerDeck, allCards: [Card]) {
        let eng = RulesEngine(deck: deck, allCards: allCards)
        _engine = StateObject(wrappedValue: eng)
        self.ai = AIPlayer(engine: eng)
    }

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Influence Points: \(engine.state.ip)").font(.headline)
                Spacer()
                Button("Draw") {
                    engine.draw(1)
                    ai.takeTurn()
                }
                Button("Play First From Hand") {
                    if let first = engine.state.hand.first {
                        engine.play(card: first)
                    }
                    ai.takeTurn()
                }
                Button("Attack With First") {
                    if let first = engine.state.battlefield.first {
                        engine.attack(attacker: first, defender: nil)
                    }
                    ai.takeTurn()
                }
                Button("Next Phase") {
                    engine.nextPhase()
                    ai.takeTurn()
                }
            }.padding(.horizontal)

            Text("Battlefield").font(.title3)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(engine.state.battlefield, id: \.self) { c in CardView(card: c).frame(width: 220) }
                }.padding(.horizontal)
            }

            Divider()
            Text("Hand").font(.title3)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(engine.state.hand, id: \.self) { c in CardView(card: c).frame(width: 220) }
                }.padding(.horizontal)
            }
        }
    }
}

