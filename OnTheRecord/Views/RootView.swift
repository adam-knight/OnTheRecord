import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Collection", systemImage: "square.grid.2x2") {
                CollectionView()
            }
            Tab("Wantlist", systemImage: "heart") {
                WantlistView()
            }
            Tab("Stats", systemImage: "chart.bar") {
                StatsView()
            }
        }
    }
}
