//
//  OnTheRecordTests.swift
//  OnTheRecordTests
//
//  Created by Adam on 25/05/2026.
//

import Foundation
import Testing
@testable import OnTheRecord

// MARK: - RecordCondition Tests

struct RecordConditionTests {
    @Test func abbreviations() {
        #expect(RecordCondition.mint.abbreviation == "M")
        #expect(RecordCondition.nearMint.abbreviation == "NM")
        #expect(RecordCondition.veryGoodPlus.abbreviation == "VG+")
        #expect(RecordCondition.veryGood.abbreviation == "VG")
        #expect(RecordCondition.goodPlus.abbreviation == "G+")
        #expect(RecordCondition.good.abbreviation == "G")
        #expect(RecordCondition.fair.abbreviation == "F")
        #expect(RecordCondition.poor.abbreviation == "P")
    }

    @Test func allCasesCount() {
        #expect(RecordCondition.allCases.count == 8)
    }

    @Test func codable() throws {
        let encoded = try JSONEncoder().encode(RecordCondition.nearMint)
        let decoded = try JSONDecoder().decode(RecordCondition.self, from: encoded)
        #expect(decoded == .nearMint)
    }
}

// MARK: - RecordFormat Tests

struct RecordFormatTests {
    @Test func rawValues() {
        #expect(RecordFormat.lp.rawValue == "LP")
        #expect(RecordFormat.ep.rawValue == "EP")
        #expect(RecordFormat.single.rawValue == "Single")
        #expect(RecordFormat.boxSet.rawValue == "Box Set")
    }

    @Test func allCasesCount() {
        #expect(RecordFormat.allCases.count == 6)
    }
}

// MARK: - StatsViewModel Tests

@MainActor
struct StatsViewModelTests {
    private func makeRecord(
        title: String = "Test",
        artist: String = "Artist",
        year: Int? = nil,
        genres: [String] = [],
        format: RecordFormat = .lp,
        isWanted: Bool = false
    ) -> Record {
        let r = Record(title: title, artist: artist, year: year, genres: genres, format: format, isWanted: isWanted)
        return r
    }

    @Test func formatBreakdownCounts() {
        let vm = StatsViewModel()
        let records = [
            makeRecord(format: .lp),
            makeRecord(format: .lp),
            makeRecord(format: .ep),
            makeRecord(format: .single),
        ]
        let breakdown = vm.formatBreakdown(from: records)
        let lpCount = breakdown.first(where: { $0.label == "LP" })?.count
        #expect(lpCount == 2)
        #expect(breakdown.count == 3)
    }

    @Test func decadeBreakdown() {
        let vm = StatsViewModel()
        let records = [
            makeRecord(year: 1971),
            makeRecord(year: 1973),
            makeRecord(year: 1985),
            makeRecord(year: nil),  // excluded
        ]
        let breakdown = vm.decadeBreakdown(from: records)
        #expect(breakdown.count == 2)
        let seventies = breakdown.first(where: { $0.label == "1970s" })
        #expect(seventies?.count == 2)
    }

    @Test func topGenresLimit() {
        let vm = StatsViewModel()
        let records = [
            makeRecord(genres: ["Rock", "Blues"]),
            makeRecord(genres: ["Rock", "Jazz"]),
            makeRecord(genres: ["Rock"]),
            makeRecord(genres: ["Blues"]),
            makeRecord(genres: ["Classical"]),
            makeRecord(genres: ["Country"]),
        ]
        let top3 = vm.topGenres(from: records, limit: 3)
        #expect(top3.count == 3)
        #expect(top3.first?.label == "Rock")
        #expect(top3.first?.count == 3)
    }

    @Test func topGenresEmpty() {
        let vm = StatsViewModel()
        #expect(vm.topGenres(from: []).isEmpty)
    }
}

// MARK: - AddRecordViewModel Tests

@MainActor
struct AddRecordViewModelTests {
    @Test func genresParsing() {
        let vm = AddRecordViewModel()
        vm.genreText = "Rock, Blues, Jazz"
        #expect(vm.genres == ["Rock", "Blues", "Jazz"])
    }

    @Test func genresParsingTrimsWhitespace() {
        let vm = AddRecordViewModel()
        vm.genreText = "  Rock ,  Blues  "
        #expect(vm.genres == ["Rock", "Blues"])
    }

    @Test func genresEmpty() {
        let vm = AddRecordViewModel()
        vm.genreText = ""
        #expect(vm.genres.isEmpty)
    }

    @Test func yearParsing() {
        let vm = AddRecordViewModel()
        vm.yearText = "1973"
        #expect(vm.year == 1973)
    }

    @Test func yearParsingInvalidReturnsNil() {
        let vm = AddRecordViewModel()
        vm.yearText = "not a year"
        #expect(vm.year == nil)
    }

    @Test func resetClearsAllFields() {
        let vm = AddRecordViewModel()
        vm.title = "Ziggy Stardust"
        vm.artist = "David Bowie"
        vm.yearText = "1972"
        vm.reset()
        #expect(vm.title.isEmpty)
        #expect(vm.artist.isEmpty)
        #expect(vm.yearText.isEmpty)
    }

    @Test func populateFromDiscogsRelease() {
        let vm = AddRecordViewModel()
        let release = DiscogsRelease(
            id: 42,
            title: "The Dark Side of the Moon",
            artists: [DiscogsRelease.DiscogsArtist(name: "Pink Floyd")],
            year: 1973,
            labels: [DiscogsRelease.DiscogsLabel(name: "Harvest")],
            genres: ["Rock"],
            styles: ["Psychedelic Rock"],
            tracklist: [
                DiscogsRelease.DiscogsTrack(position: "A1", title: "Speak to Me", duration: "1:07")
            ],
            images: nil
        )
        vm.populate(from: release)
        #expect(vm.title == "The Dark Side of the Moon")
        #expect(vm.artist == "Pink Floyd")
        #expect(vm.yearText == "1973")
        #expect(vm.label == "Harvest")
        #expect(vm.tracks.count == 1)
        #expect(vm.tracks.first?.position == "A1")
    }
}
