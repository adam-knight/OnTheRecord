import SwiftUI

struct RecordGridCell: View {
    let record: Record

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AlbumArtView(albumArtData: record.albumArtData, albumArtURL: record.albumArtURL)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 8))

            Text(record.title)
                .font(.caption)
                .bold()
                .lineLimit(1)

            Text(record.artist)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
