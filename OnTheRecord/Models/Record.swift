import Foundation
import SwiftData

@Model
final class Record {
    // Inline defaults required for CloudKit sync
    var id: UUID = UUID()
    var title: String = ""
    var artist: String = ""
    var year: Int? = nil
    var label: String? = nil
    var genres: [String] = []
    var format: RecordFormat = RecordFormat.lp
    var vinylCondition: RecordCondition? = nil
    var sleeveCondition: RecordCondition? = nil
    var notes: String? = nil
    var dateAdded: Date = Date()
    var isWanted: Bool = false
    var rating: Int = 0
    var discogsId: String? = nil
    var albumArtURL: String? = nil
    var albumArtData: Data? = nil
    @Relationship(deleteRule: .cascade) var tracks: [Track]? = nil

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
        rating: Int = 0,
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
        self.rating = rating
        self.discogsId = discogsId
        self.albumArtURL = albumArtURL
        self.albumArtData = albumArtData
    }
}
