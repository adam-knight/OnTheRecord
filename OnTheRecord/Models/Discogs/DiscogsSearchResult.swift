import Foundation

struct DiscogsSearchResponse: Decodable {
    let results: [DiscogsSearchResult]
}

struct DiscogsSearchResult: Decodable, Identifiable {
    let id: Int
    let title: String
    let year: String?
    let format: [String]?
    let label: [String]?
    let genre: [String]?
    let thumb: String?
    let coverImage: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id, title, year, format, label, genre, thumb, type
        case coverImage = "cover_image"
    }
}
