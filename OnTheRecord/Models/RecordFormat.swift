import Foundation

enum RecordFormat: String, CaseIterable, Codable {
    case lp = "LP"
    case ep = "EP"
    case single = "Single"
    case tenInch = "10\""
    case seventyEight = "78 RPM"
    case boxSet = "Box Set"
}
