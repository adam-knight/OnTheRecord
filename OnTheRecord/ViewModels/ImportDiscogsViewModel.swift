import Foundation
import SwiftData

@Observable
@MainActor
final class ImportDiscogsViewModel {
    var username = ""
    var isFetching = false
    var fetchPage = 1
    var totalPages = 1
    var fetchedReleases: [DiscogsCollectionRelease] = []
    var errorMessage: String?
    var importResult: (imported: Int, skipped: Int)?

    var hasFetched: Bool { !isFetching && !fetchedReleases.isEmpty }
    var fetchProgress: String { "Fetching page \(fetchPage) of \(totalPages)…" }

    func fetchCollection(using service: DiscogsService) async {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isFetching = true
        fetchedReleases = []
        errorMessage = nil
        importResult = nil
        fetchPage = 1
        totalPages = 1

        do {
            repeat {
                let (releases, pages) = try await service.fetchCollectionPage(username: trimmed, page: fetchPage)
                fetchedReleases.append(contentsOf: releases)
                totalPages = pages
                fetchPage += 1
            } while fetchPage <= totalPages
        } catch {
            errorMessage = "Could not fetch collection. Check the username and try again."
        }

        isFetching = false
    }

    func importRecords(into context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Record>())) ?? []
        let existingIds = Set(existing.compactMap(\.discogsId))

        var imported = 0
        var skipped = 0

        for release in fetchedReleases {
            let idString = String(release.basicInformation.id)
            guard !existingIds.contains(idString) else {
                skipped += 1
                continue
            }
            let info = release.basicInformation
            let record = Record(
                title: info.title,
                artist: info.artists.first.map { cleanArtistName($0.name) } ?? "",
                year: (info.year == 0) ? nil : info.year,
                label: info.labels.first?.name,
                genres: info.genres ?? [],
                format: RecordFormat(discogsName: info.formats.first?.name ?? ""),
                isWanted: false,
                discogsId: idString,
                albumArtURL: info.coverImage
            )
            context.insert(record)
            imported += 1
        }

        importResult = (imported: imported, skipped: skipped)
    }

    // Discogs appends " (2)" etc. to disambiguate artists with the same name
    private func cleanArtistName(_ name: String) -> String {
        name.replacing(/\ \(\d+\)$/, with: "")
    }
}

private extension RecordFormat {
    init(discogsName: String) {
        switch discogsName.lowercased() {
        case "lp":      self = .lp
        case "ep":      self = .ep
        case "single":  self = .single
        case "10\"":    self = .tenInch
        case "78 rpm":  self = .seventyEight
        case "box set": self = .boxSet
        default:        self = .lp
        }
    }
}
