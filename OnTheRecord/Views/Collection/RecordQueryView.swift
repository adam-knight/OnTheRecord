import SwiftUI
import SwiftData

struct RecordQueryView: View {
    @Query private var records: [Record]
    let sort: RecordSort
    let searchText: String
    let viewMode: CollectionViewMode

    init(isWanted: Bool, sort: RecordSort, searchText: String, viewMode: CollectionViewMode) {
        self.sort = sort
        self.searchText = searchText
        self.viewMode = viewMode
        let wanted = isWanted
        _records = Query(filter: #Predicate<Record> { $0.isWanted == wanted })
    }

    var body: some View {
        let displayed = displayRecords
        if viewMode == .grid {
            CollectionGridView(records: displayed)
        } else {
            CollectionListView(records: displayed)
        }
    }

    private var displayRecords: [Record] {
        let sorted = sortedRecords
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.artist.localizedStandardContains(searchText)
        }
    }

    private var sortedRecords: [Record] {
        switch sort {
        case .dateAdded:
            records.sorted { $0.dateAdded > $1.dateAdded }
        case .artist:
            records.sorted {
                let c = $0.artist.localizedCompare($1.artist)
                if c != .orderedSame { return c == .orderedAscending }
                return $0.title.localizedCompare($1.title) == .orderedAscending
            }
        case .title:
            records.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .year:
            records.sorted {
                switch ($0.year, $1.year) {
                case let (y1?, y2?): return y1 > y2
                case (nil, _): return false
                case (_, nil): return true
                }
            }
        }
    }
}
