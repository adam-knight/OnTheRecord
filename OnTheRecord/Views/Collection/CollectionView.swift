import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(filter: #Predicate<Record> { !$0.isWanted }, sort: \Record.dateAdded, order: .reverse)
    private var records: [Record]

    @State private var showingAddSheet = false
    @State private var viewMode = ViewMode.grid
    @State private var searchText = ""
    @State private var addViewModel = AddRecordViewModel()

    private var filteredRecords: [Record] {
        guard !searchText.isEmpty else { return records }
        return records.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.artist.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewMode == .grid {
                    CollectionGridView(records: filteredRecords)
                } else {
                    CollectionListView(records: filteredRecords)
                }
            }
            .navigationTitle("Collection")
            .searchable(text: $searchText, prompt: "Search records")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        viewMode == .grid ? "List view" : "Grid view",
                        systemImage: viewMode == .grid ? "list.bullet" : "square.grid.2x2"
                    ) {
                        viewMode = viewMode == .grid ? .list : .grid
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add record", systemImage: "plus") {
                        addViewModel.reset()
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddRecordView(viewModel: addViewModel, isWanted: false)
            }
        }
    }

    private enum ViewMode { case grid, list }
}
