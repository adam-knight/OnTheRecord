import Foundation

enum CollectionViewMode { case grid, list }

enum RecordSort: String, CaseIterable {
    case dateAdded = "Date Added"
    case artist = "Artist"
    case title = "Title"
    case year = "Year"
}
