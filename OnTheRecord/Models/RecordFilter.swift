import Foundation

struct RecordFilter: Equatable {
    var formats: Set<RecordFormat> = []
    var genres: Set<String> = []
    var decades: Set<Int> = []
    var vinylConditions: Set<RecordCondition> = []

    var isActive: Bool {
        !formats.isEmpty || !genres.isEmpty || !decades.isEmpty || !vinylConditions.isEmpty
    }

    mutating func clear() {
        formats = []
        genres = []
        decades = []
        vinylConditions = []
    }
}
