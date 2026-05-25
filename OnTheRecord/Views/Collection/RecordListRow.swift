import SwiftUI

struct RecordListRow: View {
    let record: Record

    var body: some View {
        HStack(spacing: 12) {
            AlbumArtView(albumArtData: record.albumArtData, albumArtURL: record.albumArtURL)
                .frame(width: 52, height: 52)
                .clipShape(.rect(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .lineLimit(1)
                Text(record.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let year = record.year {
                        Text(year, format: .number.grouping(.never))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Text(record.format.rawValue)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if let vc = record.vinylCondition {
                Text(vc.abbreviation)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.quaternary)
                    .clipShape(.rect(cornerRadius: 4))
            }
        }
    }
}
