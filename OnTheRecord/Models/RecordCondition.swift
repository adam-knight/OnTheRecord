import Foundation

enum RecordCondition: String, CaseIterable, Codable {
    case mint = "Mint"
    case nearMint = "Near Mint"
    case veryGoodPlus = "Very Good Plus"
    case veryGood = "Very Good"
    case goodPlus = "Good Plus"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    var abbreviation: String {
        switch self {
        case .mint: "M"
        case .nearMint: "NM"
        case .veryGoodPlus: "VG+"
        case .veryGood: "VG"
        case .goodPlus: "G+"
        case .good: "G"
        case .fair: "F"
        case .poor: "P"
        }
    }
}
