//
//  Model.swift
//  Songs
//
//  Created by Damiaan on 11/03/2021.
//

protocol ReferableSong: Hashable {
	associatedtype ID: Hashable
	associatedtype Language: Hashable

	var id: ID {get}
	var language: Language {get}
	var originalVersion: ID? {get}
}

protocol ReferableTheme: Hashable {
	associatedtype Language: Hashable
	associatedtype ID: Hashable

	var id: ID {get}
	var language: Language {get}
}

enum SearchScope<ThemeID: Equatable>: Equatable {
	case all
	case theme(ThemeID)
}

protocol SongRegistry {
	associatedtype Language
	associatedtype Song: ReferableSong where Song.Language == Language
	associatedtype Theme: ReferableTheme where Theme.Language == Language

	var languages: [Language] {get}
	var songs: [Song] {get}

	func searchSong(_ text: String, in scope: SearchScope<Theme.ID>) -> [Song.ID]

	func groupedThemes(in language: Language) -> [[Theme]]
	func songs<Themes: Collection>(in themes: Themes) -> [Song] where Themes.Element == Theme.ID
	func translations(for song: Song.ID) -> [Song.ID]

	func themeOf(song id: Song.ID) -> Theme
//	func languageOf(theme id: Theme.ID) -> Language
//	func languageOf(song id: Song.ID) -> Language

	subscript(song: Song.ID) -> Song? {get}
	subscript(theme: Theme.ID) -> Theme? {get}
}

extension SongRegistry {
	static var allSongsScope: SearchScope<Theme.ID> { .all }
	static func themeScope(_ id: Theme.ID) -> SearchScope<Theme.ID> { .theme(id) }
}

// MARK: - Default implementations -

extension SongRegistry {
	func translation(for song: Song.ID, to language: Language) -> Song? {
		translatedSongId(for: song, to: language).flatMap {translatedID in self[translatedID]}
	}

	func translatedSongId(for song: Song.ID, to language: Language) -> Song.ID? {
		translations(for: song).first {self[$0]?.language == language}
	}
}

extension ReferableTheme {
	func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
extension ReferableSong {
	func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
