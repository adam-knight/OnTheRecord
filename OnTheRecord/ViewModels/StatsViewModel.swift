import Foundation

@Observable
@MainActor
final class StatsViewModel {
    func formatBreakdown(from records: [Record]) -> [(label: String, count: Int)] {
        Dictionary(grouping: records, by: \.format.rawValue)
            .map { (label: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func decadeBreakdown(from records: [Record]) -> [(label: String, count: Int)] {
        let withYear = records.compactMap { record -> (String, Record)? in
            guard let year = record.year else { return nil }
            let decade = (year / 10) * 10
            return ("\(decade)s", record)
        }
        return Dictionary(grouping: withYear, by: { $0.0 })
            .map { (label: $0.key, count: $0.value.count) }
            .sorted { $0.label < $1.label }
    }

    func topGenres(from records: [Record], limit: Int = 5) -> [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for record in records {
            for genre in record.genres {
                counts[genre, default: 0] += 1
            }
        }
        return counts
            .map { (label: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }
}
