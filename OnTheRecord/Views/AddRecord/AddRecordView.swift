import SwiftUI

enum AddRecordRoute: Hashable {
    case discogsSearch
    case manualEntry
}

struct AddRecordView: View {
    @Bindable var viewModel: AddRecordViewModel
    let isWanted: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var service = DiscogsService()
    @State private var path = NavigationPath()
    @State private var showingScanner = false

    var body: some View {
        NavigationStack(path: $path) {
            chooserView
                .navigationTitle(isWanted ? "Add to Wantlist" : "Add Record")
                .navigationDestination(for: AddRecordRoute.self) { route in
                    switch route {
                    case .discogsSearch:
                        DiscogsSearchView(viewModel: viewModel, service: service) {
                            path.append(AddRecordRoute.manualEntry)
                        }
                    case .manualEntry:
                        ManualEntryView(viewModel: viewModel, isWanted: isWanted)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .sheet(isPresented: $showingScanner) {
                    BarcodeScannerView { barcode in
                        showingScanner = false
                        viewModel.searchQuery = barcode
                        viewModel.searchResults = []
                        path.append(AddRecordRoute.discogsSearch)
                    }
                    .ignoresSafeArea()
                }
        }
    }

    private var chooserView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("How would you like to add a record?")
                .font(.headline)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                addButton(
                    title: "Scan Barcode",
                    subtitle: "Scan the barcode on the record sleeve",
                    icon: "barcode.viewfinder"
                ) {
                    showingScanner = true
                }

                addButton(
                    title: "Search Discogs",
                    subtitle: "Search the Discogs database",
                    icon: "magnifyingglass"
                ) {
                    viewModel.searchResults = []
                    path.append(AddRecordRoute.discogsSearch)
                }

                addButton(
                    title: "Add Manually",
                    subtitle: "Enter record details yourself",
                    icon: "pencil"
                ) {
                    path.append(AddRecordRoute.manualEntry)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private func addButton(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 36)
                    .foregroundStyle(.tint)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.quaternary.opacity(0.5))
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}
