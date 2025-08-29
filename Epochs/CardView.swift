import SwiftUI

public struct CardView: View {
    public let card: Card
    public init(card: Card) { self.card = card }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(factionGradient(card.faction))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.25), lineWidth: 1))
            
            VStack(spacing: 6) {
                HStack {
                    Text(card.name)
                        .font(.system(.headline, design: .serif))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(card.cost.asArray(), id: \.0) { item in
                            let (res, amount) = item
                            HStack(spacing: 4) {
                                Image(iconName(for: res))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                Text("\(amount)")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(.ultraThinMaterial).cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal, 10).padding(.top, 8)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(white: 0.98))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.2), lineWidth: 1))
                    Text("Art")
                        .font(.caption).foregroundColor(.secondary)
                }
                .frame(height: 160).padding(.horizontal, 10)
                
                Text(card.type.supertype ?? "")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.rulesText)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let flavor = card.flavorText, !flavor.isEmpty {
                        Divider().opacity(0.3)
                        Text(flavor)
                            .font(.system(size: 11, design: .serif))
                            .italic()
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.65)))
                .padding(.horizontal, 10)
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("\(card.number)/180 • \(card.setName) \(card.rarity.display)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }
            
            if let stats = card.stats, card.type.kind == .citizen {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(stats.attack)/\(stats.defense)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.85)))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.2), lineWidth: 1))
                            .padding(.trailing, 8).padding(.bottom, 40)
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Image("icon_pillar")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(.trailing, 12).padding(.top, 34)
                }
                Spacer()
            }
        }
        .aspectRatio(63/88, contentMode: .fit)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        .padding(6)
    }
    
    private func iconName(for res: Resource) -> String {
        switch res {
        case .knowledge: return "icon_knowledge"
        case .materials: return "icon_materials"
        case .influence: return "icon_influence"
        }
    }
    
    private func factionGradient(_ faction: String) -> LinearGradient {
        switch faction.lowercased() {
        case "inventors":
            return LinearGradient(colors: [Color(red:0.34,green:0.54,blue:0.92), .gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case "builders":
            return LinearGradient(colors: [Color.green.opacity(0.6), Color.gray.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case "explorers":
            return LinearGradient(colors: [Color(red:0.65,green:0.2,blue:0.15), Color.orange.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case "artists":
            return LinearGradient(colors: [Color.white.opacity(0.9), Color.yellow.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        case "leaders":
            return LinearGradient(colors: [Color.purple.opacity(0.6), Color.black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        }
    }
}