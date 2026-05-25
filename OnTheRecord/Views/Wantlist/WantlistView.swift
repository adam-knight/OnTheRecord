import SwiftUI
import SwiftData

struct WantlistView: View {
    @Query(filter: #Predicate<Record> { $0.isWanted }, sort: \Record.dateAdded, order: .reverse)
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
            .navigationTitle("Wantlist")
            .searchable(text: $searchText, prompt: "Search wantlist")
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
                    Button("Add to wantlist", systemImage: "plus") {
                        addViewModel.reset()
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddRecordView(viewModel: addViewModel, isWanted: true)
            }
            .overlay {
                if records.isEmpty {
                    ContentUnavailableView(
                        "Nothing on your wantlist",
                        systemImage: "heart",
                        description: Text("Tap + to add records you're hunting for.")
                    )
                }
            }
        }
    }

    private enum ViewMode { case grid, list }
}
