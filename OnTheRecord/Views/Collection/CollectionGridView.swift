import SwiftUI

struct CollectionGridView: View {
    let records: [Record]

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(records) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordGridCell(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
