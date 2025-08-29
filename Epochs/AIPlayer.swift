import Foundation

public final class AIPlayer {
    private let engine: RulesEngine

    public init(engine: RulesEngine) {
        self.engine = engine
    }

    /// Execute a very basic turn for the AI by drawing, playing and attacking.
    public func takeTurn() {
        repeat {
            switch engine.state.phase {
            case .start:
                engine.draw(1)
            case .main:
                if let card = engine.state.hand.first {
                    engine.play(card: card)
                }
            case .combat:
                if let attacker = engine.state.battlefield.first {
                    engine.attack(attacker: attacker, defender: nil)
                }
            case .end:
                break
            }
            engine.nextPhase()
        } while engine.state.phase != .start
    }
}

