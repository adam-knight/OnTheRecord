import Foundation

@Observable
@MainActor
final class DiscogsService {
    private let token: String?
    private let baseURL = URL(string: "https://api.discogs.com")!

    init() {
        token = Bundle.main.infoDictionary?["DISCOGS_TOKEN"] as? String
    }

    func search(query: String) async throws -> [DiscogsSearchResult] {
        let url = baseURL
            .appending(path: "database/search")
            .appending(queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: "release")
            ])
        return try await fetchSearchResults(from: url)
    }

    func searchByBarcode(_ barcode: String) async throws -> [DiscogsSearchResult] {
        let url = baseURL
            .appending(path: "database/search")
            .appending(queryItems: [
                URLQueryItem(name: "barcode", value: barcode),
                URLQueryItem(name: "type", value: "release")
            ])
        return try await fetchSearchResults(from: url)
    }

    func fetchCollectionPage(username: String, page: Int) async throws -> (releases: [DiscogsCollectionRelease], totalPages: Int) {
        let url = baseURL
            .appending(path: "users/\(username)/collection/folders/0/releases")
            .appending(queryItems: [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: "100")
            ])
        let (data, _) = try await URLSession.shared.data(for: authorizedRequest(for: url))
        let response = try JSONDecoder().decode(DiscogsCollectionResponse.self, from: data)
        return (response.releases, response.pagination.pages)
    }

    func release(id: Int) async throws -> DiscogsRelease {
        let url = baseURL.appending(path: "releases/\(id)")
        let (data, _) = try await URLSession.shared.data(for: authorizedRequest(for: url))
        return try JSONDecoder().decode(DiscogsRelease.self, from: data)
    }

    private func fetchSearchResults(from url: URL) async throws -> [DiscogsSearchResult] {
        let (data, _) = try await URLSession.shared.data(for: authorizedRequest(for: url))
        let response = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
        return response.results
    }

    private func authorizedRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("OnTheRecord/1.0", forHTTPHeaderField: "User-Agent")
        if let token {
            request.setValue("Discogs token=\(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
