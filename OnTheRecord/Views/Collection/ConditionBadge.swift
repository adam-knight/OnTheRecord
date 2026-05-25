import SwiftUI

struct ConditionBadge: View {
    let label: String
    let condition: RecordCondition

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(condition.abbreviation)
                .font(.caption)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(.rect(cornerRadius: 6))
        }
    }

    private var color: Color {
        switch condition {
        case .mint, .nearMint: .green
        case .veryGoodPlus, .veryGood: .blue
        case .goodPlus, .good: .orange
        case .fair, .poor: .red
        }
    }
}
