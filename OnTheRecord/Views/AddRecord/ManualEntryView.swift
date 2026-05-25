import SwiftUI
import SwiftData
import PhotosUI

struct ManualEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: AddRecordViewModel
    let existingRecord: Record?
    let isWanted: Bool

    @State private var newTrackPosition = ""
    @State private var newTrackTitle = ""

    init(viewModel: AddRecordViewModel, existingRecord: Record? = nil, isWanted: Bool = false) {
        self.viewModel = viewModel
        self.existingRecord = existingRecord
        self.isWanted = isWanted
    }

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Title", text: $viewModel.title)
                TextField("Artist", text: $viewModel.artist)
            }

            Section("Release") {
                TextField("Year", text: $viewModel.yearText)
                    .keyboardType(.numberPad)
                TextField("Label", text: $viewModel.label)
                Picker("Format", selection: $viewModel.format) {
                    ForEach(RecordFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
            }

            Section("Condition") {
                Picker("Vinyl", selection: $viewModel.vinylCondition) {
                    Text("Unknown").tag(Optional<RecordCondition>.none)
                    ForEach(RecordCondition.allCases, id: \.self) { c in
                        Text(c.rawValue).tag(Optional(c))
                    }
                }
                Picker("Sleeve", selection: $viewModel.sleeveCondition) {
                    Text("Unknown").tag(Optional<RecordCondition>.none)
                    ForEach(RecordCondition.allCases, id: \.self) { c in
                        Text(c.rawValue).tag(Optional(c))
                    }
                }
            }

            Section("Genres") {
                TextField("e.g. Rock, Blues", text: $viewModel.genreText)
            }

            Section("Album Art") {
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    albumArtLabel
                }
                .onChange(of: viewModel.selectedPhoto) {
                    Task { await viewModel.loadPhotoData() }
                }
                if viewModel.albumArtData != nil {
                    Button("Remove Photo", role: .destructive) {
                        viewModel.albumArtData = nil
                        viewModel.selectedPhoto = nil
                    }
                }
            }

            Section {
                ForEach($viewModel.tracks) { $track in
                    HStack {
                        Text(track.position)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 36, alignment: .leading)
                        TextField("Track title", text: $track.title)
                    }
                }
                .onDelete { viewModel.tracks.remove(atOffsets: $0) }

                HStack {
                    TextField("Pos", text: $newTrackPosition)
                        .frame(width: 48)
                    TextField("Track title", text: $newTrackTitle)
                    Button("Add track", systemImage: "plus.circle.fill") {
                        guard !newTrackTitle.isEmpty else { return }
                        viewModel.tracks.append(
                            .init(position: newTrackPosition, title: newTrackTitle, duration: "")
                        )
                        newTrackPosition = ""
                        newTrackTitle = ""
                    }
                    .labelStyle(.iconOnly)
                    .disabled(newTrackTitle.isEmpty)
                }
            } header: {
                Text("Tracks")
            }

            Section("Notes") {
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...)
            }
        }
        .navigationTitle(existingRecord == nil ? "Add Record" : "Edit Record")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveRecord()
                    dismiss()
                }
                .disabled(viewModel.title.isEmpty || viewModel.artist.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    @ViewBuilder
    private var albumArtLabel: some View {
        if let data = viewModel.albumArtData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .clipShape(.rect(cornerRadius: 8))
        } else if let urlString = viewModel.albumArtURL, !urlString.isEmpty {
            AsyncImage(url: URL(string: urlString)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .clipShape(.rect(cornerRadius: 8))
                } else {
                    Label("Choose Photo", systemImage: "photo")
                }
            }
        } else {
            Label("Choose Photo", systemImage: "photo")
        }
    }

    private func saveRecord() {
        if let record = existingRecord {
            updateRecord(record)
        } else {
            viewModel.save(into: context, isWanted: isWanted)
        }
    }

    private func updateRecord(_ record: Record) {
        record.title = viewModel.title
        record.artist = viewModel.artist
        record.year = viewModel.year
        record.label = viewModel.label.isEmpty ? nil : viewModel.label
        record.genres = viewModel.genres
        record.format = viewModel.format
        record.vinylCondition = viewModel.vinylCondition
        record.sleeveCondition = viewModel.sleeveCondition
        record.notes = viewModel.notes.isEmpty ? nil : viewModel.notes
        record.discogsId = viewModel.discogsId
        record.albumArtURL = viewModel.albumArtURL
        if let data = viewModel.albumArtData {
            record.albumArtData = data
        }
        record.tracks?.forEach { context.delete($0) }
        record.tracks = []
        for draft in viewModel.tracks {
            let track = Track(
                position: draft.position,
                title: draft.title,
                duration: draft.duration.isEmpty ? nil : draft.duration
            )
            track.record = record
            context.insert(track)
        }
    }
}
