import Foundation

struct DiscogsRelease: Decodable {
    let id: Int
    let title: String
    let artists: [DiscogsArtist]
    let year: Int?
    let labels: [DiscogsLabel]
    let genres: [String]?
    let styles: [String]?
    let tracklist: [DiscogsTrack]
    let images: [DiscogsImage]?

    struct DiscogsArtist: Decodable {
        let name: String
    }

    struct DiscogsLabel: Decodable {
        let name: String
    }

    struct DiscogsTrack: Decodable {
        let position: String
        let title: String
        let duration: String?
    }

    struct DiscogsImage: Decodable {
        let type: String
        let uri: String
    }
}
