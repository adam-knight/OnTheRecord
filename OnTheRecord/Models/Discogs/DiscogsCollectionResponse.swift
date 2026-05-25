import Foundation

struct DiscogsCollectionResponse: Decodable {
    let releases: [DiscogsCollectionRelease]
    let pagination: DiscogsPagination
}

struct DiscogsPagination: Decodable {
    let pages: Int
    let page: Int
    let items: Int
}

struct DiscogsCollectionRelease: Decodable, Identifiable {
    let id: Int
    let basicInformation: DiscogsCollectionBasicInfo

    enum CodingKeys: String, CodingKey {
        case id
        case basicInformation = "basic_information"
    }
}

struct DiscogsCollectionBasicInfo: Decodable {
    let id: Int
    let title: String
    let year: Int?
    let coverImage: String?
    let formats: [DiscogsCollectionFormat]
    let labels: [DiscogsCollectionLabel]
    let artists: [DiscogsCollectionArtist]
    let genres: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, year, formats, labels, artists, genres
        case coverImage = "cover_image"
    }
}

struct DiscogsCollectionFormat: Decodable {
    let name: String
}

struct DiscogsCollectionLabel: Decodable {
    let name: String
}

struct DiscogsCollectionArtist: Decodable {
    let name: String
}
