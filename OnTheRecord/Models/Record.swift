import Foundation
import SwiftData

@Model
final class Record {
    var id: UUID
    var title: String
    var artist: String
    var year: Int?
    var label: String?
    var genres: [String]
    var format: RecordFormat
    var vinylCondition: RecordCondition?
    var sleeveCondition: RecordCondition?
    var notes: String?
    var dateAdded: Date
    var isWanted: Bool
    var discogsId: String?
    var albumArtURL: String?
    var albumArtData: Data?
    @Relationship(deleteRule: .cascade) var tracks: [Track]?

    init(
        title: String,
        artist: String,
        year: Int? = nil,
        label: String? = nil,
        genres: [String] = [],
        format: RecordFormat = .lp,
        vinylCondition: RecordCondition? = nil,
        sleeveCondition: RecordCondition? = nil,
        notes: String? = nil,
        isWanted: Bool = false,
        discogsId: String? = nil,
        albumArtURL: String? = nil,
        albumArtData: Data? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.year = year
        self.label = label
        self.genres = genres
        self.format = format
        self.vinylCondition = vinylCondition
        self.sleeveCondition = sleeveCondition
        self.notes = notes
        self.dateAdded = Date()
        self.isWanted = isWanted
        self.discogsId = discogsId
        self.albumArtURL = albumArtURL
        self.albumArtData = albumArtData
    }
}
