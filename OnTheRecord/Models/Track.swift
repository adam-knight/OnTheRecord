import Foundation
import SwiftData

@Model
final class Track {
    var position: String
    var title: String
    var duration: String?
    var record: Record?

    init(position: String, title: String, duration: String? = nil) {
        self.position = position
        self.title = title
        self.duration = duration
    }
}
