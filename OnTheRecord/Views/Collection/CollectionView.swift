import SwiftUI
import SwiftData

struct CollectionView: View {
    @State private var sort = RecordSort.dateAdded
    @State private var viewMode = CollectionViewMode.grid
    @State private var searchText = ""
    @State private var filter = RecordFilter()
    @State private var showingFilterSheet = false
    @State private var showingAddSheet = false
    @State private var addViewModel = AddRecordViewModel()

    var body: some View {
        NavigationStack {
            RecordQueryView(isWanted: false, sort: sort, searchText: searchText, viewMode: viewMode, filter: filter)
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
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort by", selection: $sort) {
                                ForEach(RecordSort.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            "Filter",
                            systemImage: filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
                        ) {
                            showingFilterSheet = true
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add record", systemImage: "plus") {
                            addViewModel.reset()
                            showingAddSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingFilterSheet) {
                    FilterSheetView(filter: $filter, isWanted: false)
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddRecordView(viewModel: addViewModel, isWanted: false)
                }
        }
    }
}
