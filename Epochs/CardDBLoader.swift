import Foundation

public final class CardDB {
    public static func load(from url: URL) throws -> [Card] {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Card].self, from: data)
    }
}