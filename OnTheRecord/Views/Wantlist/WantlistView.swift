import SwiftUI
import SwiftData

struct WantlistView: View {
    @Query(filter: #Predicate<Record> { $0.isWanted })
    private var allWanted: [Record]

    @State private var sort = RecordSort.dateAdded
    @State private var viewMode = CollectionViewMode.grid
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var addViewModel = AddRecordViewModel()

    var body: some View {
        NavigationStack {
            RecordQueryView(isWanted: true, sort: sort, searchText: searchText, viewMode: viewMode)
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
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort by", selection: $sort) {
                                ForEach(RecordSort.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
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
                    if allWanted.isEmpty {
                        ContentUnavailableView(
                            "Nothing on your wantlist",
                            systemImage: "heart",
                            description: Text("Tap + to add records you're hunting for.")
                        )
                    }
                }
        }
    }
}
