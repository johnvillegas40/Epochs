//
//  EpochsTests.swift
//  EpochsTests
//
//  Created by Johnny Villegas on 8/29/25.
//

import Testing
@testable import Epochs

struct EpochsTests {
    private func loadCards() throws -> [Card] {
        let testDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let rootDir = testDir.deletingLastPathComponent()
        let url = rootDir.appendingPathComponent("Epochs/CardDB.json")
        return try CardDB.load(from: url)
    }
    
    private func validate(deck: PlayerDeck) -> Bool {
        let minimumDeckSize = 60
        let maxCopiesPerCard = 4
        guard deck.cardIDs.count >= minimumDeckSize else { return false }
        let counts = Dictionary(grouping: deck.cardIDs, by: { $0 }).mapValues { $0.count }
        return counts.values.allSatisfy { $0 <= maxCopiesPerCard }
    }
    
    @Test func cardDecoding() throws {
        let cards = try loadCards()
        #expect(!cards.isEmpty)
        #expect(cards.first?.name == "Apprentice Scholar")
    }
    
    @Test func deckValidation() throws {
        let cards = try loadCards()
        let validDeck = PlayerDeck(name: "Valid", cardIDs: cards.prefix(60).map { $0.id })
        #expect(validate(deck: validDeck))
        let smallDeck = PlayerDeck(name: "Small", cardIDs: cards.prefix(59).map { $0.id })
        #expect(!validate(deck: smallDeck))
        var overCopies = cards.prefix(60).map { $0.id }
        if let first = cards.first?.id {
            for i in 0..<5 { overCopies[i] = first }
        }
        let tooManyCopiesDeck = PlayerDeck(name: "TooManyCopies", cardIDs: overCopies)
        #expect(!validate(deck: tooManyCopiesDeck))
    }
    
    @Test func rulesEngineInitialization() throws {
        let cards = try loadCards()
        let deck = PlayerDeck(name: "Deck", cardIDs: cards.prefix(60).map { $0.id })
        let engine = RulesEngine(deck: deck, allCards: cards)
        #expect(engine.state.hand.count == 7)
        #expect(engine.state.library.count == deck.cardIDs.count - 7)
        #expect(engine.state.ip == 20)
    }
    
    @Test func rulesEnginePlayAndAttack() throws {
        let cards = try loadCards()
        guard let attacker = cards.first(where: { $0.stats != nil }) else {
            return
        }
        let deck = PlayerDeck(name: "Attack", cardIDs: Array(repeating: attacker.id, count: 60))
        let engine = RulesEngine(deck: deck, allCards: cards)
        let card = engine.state.hand.first!
        engine.play(card: card)
        #expect(engine.state.battlefield.contains(card))
        engine.nextPhase()
        engine.nextPhase()
        let initialIP = engine.state.ip
        engine.attack(attacker: card, defender: nil)
        if let stats = card.stats {
            #expect(engine.state.ip == max(0, initialIP - stats.attack))
        }
    }
}
