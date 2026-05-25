import SwiftUI

struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(track.position)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)
            Text(track.title)
            Spacer()
            if let duration = track.duration, !duration.isEmpty {
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
