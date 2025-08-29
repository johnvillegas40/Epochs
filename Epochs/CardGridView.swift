import SwiftUI

struct CardGridView: View {
    let cards: [Card]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 8)], spacing: 8) {
                ForEach(cards, id: \.id) { card in
                    CardView(card: card)
                }
            }
            .padding()
        }
    }
}
