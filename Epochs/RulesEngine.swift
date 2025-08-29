import Foundation

public enum GamePhase: String {
    case start
    case main
    case combat
    case end
}

public struct GameState {
    public var phase: GamePhase = .start
    public var ip: Int = 20
    public var hand: [Card] = []
    public var battlefield: [Card] = []
    public var library: [Card] = []
}

public final class RulesEngine: ObservableObject {
    @Published public private(set) var state: GameState

    public init(deck: PlayerDeck, allCards: [Card]) {
        var deckCards: [Card] = deck.cardIDs.compactMap { id in
            allCards.first { $0.id == id }
        }
        deckCards.shuffle()
        self.state = GameState(phase: .start, ip: 20, hand: [], battlefield: [], library: deckCards)
        draw(7)
    }

    public func nextPhase() {
        switch state.phase {
        case .start:
            // Resource generation at the beginning of the turn
            state.ip += 1
            state.phase = .main
        case .main:
            state.phase = .combat
        case .combat:
            state.phase = .end
        case .end:
            state.phase = .start
        }
    }

    public func draw(_ n: Int) {
        for _ in 0..<n {
            guard !state.library.isEmpty else { break }
            state.hand.append(state.library.removeFirst())
        }
    }

    public func play(card: Card) {
        guard let index = state.hand.firstIndex(of: card) else { return }
        state.hand.remove(at: index)
        state.battlefield.append(card)
    }

    // Basic combat resolution. If defender is nil, attacker deals damage to IP.
    public func attack(attacker: Card, defender: Card?) {
        guard state.phase == .combat else { return }
        guard let attackerStats = attacker.stats else { return }
        if let defender = defender, let defenderStats = defender.stats {
            if attackerStats.attack >= defenderStats.defense {
                if let defIndex = state.battlefield.firstIndex(of: defender) {
                    state.battlefield.remove(at: defIndex)
                }
            }
            if defenderStats.attack >= attackerStats.defense {
                if let atkIndex = state.battlefield.firstIndex(of: attacker) {
                    state.battlefield.remove(at: atkIndex)
                }
            }
        } else {
            state.ip = max(0, state.ip - attackerStats.attack)
        }
    }
}

