import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(filter: #Predicate<Record> { !$0.isWanted })
    private var collection: [Record]

    @Query(filter: #Predicate<Record> { $0.isWanted })
    private var wantlist: [Record]

    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            List {
                summarySection
                formatSection
                decadeSection
                genreSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats")
        }
    }

    private var summarySection: some View {
        Section("Overview") {
            HStack {
                statTile(value: collection.count, label: "In Collection")
                Divider()
                statTile(value: wantlist.count, label: "On Wantlist")
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func statTile(value: Int, label: String) -> some View {
        VStack {
            Text(value, format: .number)
                .font(.title)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var formatSection: some View {
        let data = viewModel.formatBreakdown(from: collection)
        return Section("By Format") {
            if data.isEmpty {
                Text("No records yet")
                    .foregroundStyle(.secondary)
            } else {
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Format", item.label),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(.tint)
                }
                .frame(height: 160)
                .padding(.vertical, 8)
            }
        }
    }

    private var decadeSection: some View {
        let data = viewModel.decadeBreakdown(from: collection)
        return Section("By Decade") {
            if data.isEmpty {
                Text("No records with release years")
                    .foregroundStyle(.secondary)
            } else {
                Chart(data, id: \.label) { item in
                    BarMark(
                        x: .value("Decade", item.label),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(.tint)
                }
                .frame(height: 160)
                .padding(.vertical, 8)
            }
        }
    }

    private var genreSection: some View {
        let data = viewModel.topGenres(from: collection)
        return Section("Top Genres") {
            if data.isEmpty {
                Text("No genres tagged")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(data, id: \.label) { item in
                    HStack {
                        Text(item.label)
                        Spacer()
                        Text(item.count, format: .number)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
