import Foundation

public enum Resource: String, Codable, CaseIterable {
    case knowledge, materials, influence
}

public enum Rarity: String, Codable {
    case common, uncommon, rare, mythic
    var display: String {
        switch self {
        case .common: return "◆ C"
        case .uncommon: return "★ U"
        case .rare: return "✦ R"
        case .mythic: return "✪ M"
        }
    }
}

public struct Cost: Codable, Hashable {
    public var knowledge: Int
    public var materials: Int
    public var influence: Int

    public init(knowledge: Int = 0, materials: Int = 0, influence: Int = 0) {
        self.knowledge = knowledge
        self.materials = materials
        self.influence = influence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        knowledge = try container.decodeIfPresent(Int.self, forKey: .knowledge) ?? 0
        materials = try container.decodeIfPresent(Int.self, forKey: .materials) ?? 0
        influence = try container.decodeIfPresent(Int.self, forKey: .influence) ?? 0
    }

    public func asArray() -> [(Resource, Int)] {
        var arr: [(Resource, Int)] = []
        if knowledge > 0 { arr.append((.knowledge, knowledge)) }
        if materials > 0 { arr.append((.materials, materials)) }
        if influence > 0 { arr.append((.influence, influence)) }
        return arr
    }
}

public struct Stats: Codable, Hashable { public var attack: Int; public var defense: Int }

public struct CardType: Codable, Hashable {
    public enum Kind: String, Codable { case citizen, invention, wonder, event, territory }
    public var kind: Kind
    public var supertype: String?
}

public struct Card: Codable, Identifiable, Hashable {
    public let id: String
    public let number: Int
    public let name: String
    public let faction: String
    public let type: CardType
    public let rarity: Rarity
    public let cost: Cost
    public let stats: Stats?
    public let rulesText: String
    public let flavorText: String?
    public let setName: String
}