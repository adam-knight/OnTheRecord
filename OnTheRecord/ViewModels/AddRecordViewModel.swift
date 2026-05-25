import Foundation
import SwiftData
import PhotosUI
import SwiftUI

@Observable
@MainActor
final class AddRecordViewModel {
    // Form state
    var title = ""
    var artist = ""
    var yearText = ""
    var label = ""
    var genreText = ""
    var format: RecordFormat = .lp
    var vinylCondition: RecordCondition? = nil
    var sleeveCondition: RecordCondition? = nil
    var notes = ""
    var albumArtURL: String? = nil
    var albumArtData: Data? = nil
    var selectedPhoto: PhotosPickerItem? = nil
    var discogsId: String? = nil
    var tracks: [DraftTrack] = []

    // Search state
    var searchQuery = ""
    var searchResults: [DiscogsSearchResult] = []
    var isSearching = false
    var searchError: String? = nil

    // Flow state
    var showBarcodeScannerStep = false
    var showDiscogsSearchStep = false

    var year: Int? { Int(yearText) }

    var genres: [String] {
        genreText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    struct DraftTrack: Identifiable {
        var id = UUID()
        var position: String
        var title: String
        var duration: String
    }

    func populate(from release: DiscogsRelease) {
        title = release.title
        artist = release.artists.first?.name ?? ""
        yearText = release.year.map(String.init) ?? ""
        label = release.labels.first?.name ?? ""
        genreText = (release.genres ?? []).joined(separator: ", ")
        discogsId = String(release.id)
        albumArtURL = release.images?.first(where: { $0.type == "primary" })?.uri
            ?? release.images?.first?.uri
        tracks = release.tracklist.map {
            DraftTrack(position: $0.position, title: $0.title, duration: $0.duration ?? "")
        }
    }

    func populate(from searchResult: DiscogsSearchResult) {
        let parts = searchResult.title.split(separator: " - ", maxSplits: 1)
        if parts.count == 2 {
            artist = String(parts[0])
            title = String(parts[1])
        } else {
            title = searchResult.title
        }
        yearText = searchResult.year ?? ""
        label = searchResult.label?.first ?? ""
        genreText = (searchResult.genre ?? []).joined(separator: ", ")
        albumArtURL = searchResult.coverImage
        discogsId = String(searchResult.id)
    }

    func loadPhotoData() async {
        guard let item = selectedPhoto else { return }
        albumArtData = try? await item.loadTransferable(type: Data.self)
    }

    func save(into context: ModelContext, isWanted: Bool) {
        let record = Record(
            title: title,
            artist: artist,
            year: year,
            label: label.isEmpty ? nil : label,
            genres: genres,
            format: format,
            vinylCondition: vinylCondition,
            sleeveCondition: sleeveCondition,
            notes: notes.isEmpty ? nil : notes,
            isWanted: isWanted,
            discogsId: discogsId,
            albumArtURL: albumArtURL,
            albumArtData: albumArtData
        )
        context.insert(record)

        for draft in tracks {
            let track = Track(
                position: draft.position,
                title: draft.title,
                duration: draft.duration.isEmpty ? nil : draft.duration
            )
            track.record = record
            context.insert(track)
        }
    }

    func populateFromRecord(_ record: Record) {
        title = record.title
        artist = record.artist
        yearText = record.year.map(String.init) ?? ""
        label = record.label ?? ""
        genreText = record.genres.joined(separator: ", ")
        format = record.format
        vinylCondition = record.vinylCondition
        sleeveCondition = record.sleeveCondition
        notes = record.notes ?? ""
        discogsId = record.discogsId
        albumArtURL = record.albumArtURL
        albumArtData = record.albumArtData
        tracks = record.tracks?.sorted { $0.position < $1.position }.map {
            DraftTrack(position: $0.position, title: $0.title, duration: $0.duration ?? "")
        } ?? []
    }

    func reset() {
        title = ""; artist = ""; yearText = ""; label = ""; genreText = ""
        format = .lp; vinylCondition = nil; sleeveCondition = nil; notes = ""
        albumArtURL = nil; albumArtData = nil; selectedPhoto = nil; discogsId = nil
        tracks = []; searchQuery = ""; searchResults = []; searchError = nil
        showBarcodeScannerStep = false; showDiscogsSearchStep = false
    }
}
