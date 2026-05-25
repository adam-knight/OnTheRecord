import SwiftUI
import SwiftData

struct FilterSheetView: View {
    @Binding var filter: RecordFilter
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [Record]

    init(filter: Binding<RecordFilter>, isWanted: Bool) {
        _filter = filter
        let wanted = isWanted
        _records = Query(filter: #Predicate<Record> { $0.isWanted == wanted })
    }

    private var availableFormats: [RecordFormat] {
        Array(Set(records.map(\.format))).sorted { $0.rawValue < $1.rawValue }
    }

    private var availableDecades: [Int] {
        Array(Set(records.compactMap(\.year).map { ($0 / 10) * 10 })).sorted()
    }

    private var availableGenres: [String] {
        Array(Set(records.flatMap(\.genres))).sorted()
    }

    private var availableConditions: [RecordCondition] {
        Array(Set(records.compactMap(\.vinylCondition))).sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                if !availableFormats.isEmpty {
                    Section("Format") {
                        ForEach(availableFormats, id: \.self) { format in
                            toggle(format.rawValue, in: $filter.formats, value: format)
                        }
                    }
                }

                if !availableDecades.isEmpty {
                    Section("Decade") {
                        ForEach(availableDecades, id: \.self) { decade in
                            toggle("\(decade)s", in: $filter.decades, value: decade)
                        }
                    }
                }

                if !availableGenres.isEmpty {
                    Section("Genre") {
                        ForEach(availableGenres, id: \.self) { genre in
                            toggle(genre, in: $filter.genres, value: genre)
                        }
                    }
                }

                if !availableConditions.isEmpty {
                    Section("Vinyl Condition") {
                        ForEach(availableConditions, id: \.self) { condition in
                            toggle(condition.rawValue, in: $filter.vinylConditions, value: condition)
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        filter.clear()
                    }
                    .disabled(!filter.isActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func toggle<T: Hashable>(_ label: String, in set: Binding<Set<T>>, value: T) -> some View {
        Toggle(label, isOn: Binding(
            get: { set.wrappedValue.contains(value) },
            set: { on in
                if on { set.wrappedValue.insert(value) } else { set.wrappedValue.remove(value) }
            }
        ))
    }
}
