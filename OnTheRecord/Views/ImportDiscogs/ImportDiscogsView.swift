import SwiftUI
import SwiftData

struct ImportDiscogsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ImportDiscogsViewModel()
    @State private var service = DiscogsService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Discogs username", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            Task { await viewModel.fetchCollection(using: service) }
                        }
                } footer: {
                    Text("Enter your Discogs username to import your collection.")
                }

                Section {
                    Button("Fetch Collection") {
                        Task { await viewModel.fetchCollection(using: service) }
                    }
                    .disabled(viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isFetching)
                }

                if viewModel.isFetching {
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text(viewModel.fetchProgress)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                if viewModel.hasFetched {
                    Section("Preview") {
                        LabeledContent("Records found", value: viewModel.fetchedReleases.count.formatted())
                    }

                    Section {
                        Button("Import into Collection") {
                            viewModel.importRecords(into: context)
                        }
                    } footer: {
                        Text("Records already in your collection will be skipped.")
                    }
                }

                if let result = viewModel.importResult {
                    Section("Done") {
                        LabeledContent("Imported", value: result.imported.formatted())
                        LabeledContent("Already in collection", value: result.skipped.formatted())
                    }
                }
            }
            .navigationTitle("Import from Discogs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
