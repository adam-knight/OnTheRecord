import SwiftUI

struct DiscogsSearchView: View {
    @Bindable var viewModel: AddRecordViewModel
    let service: DiscogsService
    let onResultLoaded: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        Group {
            if viewModel.isSearching {
                ProgressView("Searching…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.searchError {
                ContentUnavailableView(
                    "Search Failed",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchQuery)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.searchResults) { result in
                            Button {
                                loadRelease(result)
                            } label: {
                                DiscogsResultRow(result: result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("Search Discogs")
        .searchable(text: $viewModel.searchQuery, prompt: "Artist, album, label…")
        .onSubmit(of: .search) {
            Task { await performSearch() }
        }
        .task(id: viewModel.searchQuery) {
            guard !viewModel.searchQuery.isEmpty else { return }
            // Debounce: cancel and restart on each keystroke, search after 600ms pause
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    private func performSearch() async {
        guard !viewModel.searchQuery.isEmpty else { return }
        viewModel.isSearching = true
        viewModel.searchError = nil
        do {
            viewModel.searchResults = try await service.search(query: viewModel.searchQuery)
        } catch {
            viewModel.searchError = error.localizedDescription
        }
        viewModel.isSearching = false
    }

    private func loadRelease(_ result: DiscogsSearchResult) {
        Task {
            viewModel.isSearching = true
            do {
                let release = try await service.release(id: result.id)
                viewModel.populate(from: release)
            } catch {
                viewModel.populate(from: result)
            }
            viewModel.isSearching = false
            onResultLoaded()
        }
    }
}
