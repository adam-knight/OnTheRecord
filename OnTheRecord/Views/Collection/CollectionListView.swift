import SwiftUI

struct CollectionListView: View {
    let records: [Record]

    var body: some View {
        List(records) { record in
            NavigationLink {
                RecordDetailView(record: record)
            } label: {
                RecordListRow(record: record)
            }
        }
        .listStyle(.plain)
    }
}
