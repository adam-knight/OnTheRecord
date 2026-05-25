import SwiftUI
import SwiftData

struct RecordDetailView: View {
    @Environment(\.modelContext) private var context
    var record: Record

    @State private var showingEditSheet = false
    @State private var editViewModel = AddRecordViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AlbumArtView(albumArtData: record.albumArtData, albumArtURL: record.albumArtURL)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(record.title)
                        .font(.title2)
                        .bold()

                    Text(record.artist)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        if let year = record.year {
                            Text(year, format: .number.grouping(.never))
                        }
                        Text(record.format.rawValue)
                        if let label = record.label {
                            Text(label)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)

                    if record.vinylCondition != nil || record.sleeveCondition != nil {
                        HStack(spacing: 12) {
                            if let vc = record.vinylCondition {
                                ConditionBadge(label: "Vinyl", condition: vc)
                            }
                            if let sc = record.sleeveCondition {
                                ConditionBadge(label: "Sleeve", condition: sc)
                            }
                        }
                    }

                    if !record.genres.isEmpty {
                        Text(record.genres.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                if let tracks = record.tracks, !tracks.isEmpty {
                    Divider()
                    Text("Tracklist")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    ForEach(tracks.sorted { $0.position < $1.position }) { track in
                        TrackRow(track: track)
                        Divider().padding(.leading, 52)
                    }
                }

                if let notes = record.notes, !notes.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                Divider()

                Button(
                    record.isWanted ? "Move to Collection" : "Add to Wantlist",
                    systemImage: record.isWanted ? "tray.and.arrow.down" : "heart"
                ) {
                    record.isWanted.toggle()
                }
                .buttonStyle(.bordered)
                .padding()
            }
        }
        .navigationTitle(record.artist)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil") {
                    editViewModel.reset()
                    editViewModel.populateFromRecord(record)
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                ManualEntryView(viewModel: editViewModel, existingRecord: record, isWanted: record.isWanted)
            }
        }
    }
}
