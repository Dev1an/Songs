//
//  BrowserState.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 08/03/2021.
//

import SwiftUI

protocol NavigatbleSong {
	associatedtype ID: Hashable
	associatedtype Language: Hashable

	var id: ID {get}
	var language: Language {get}
	var originalVersion: ID? {get}
}

protocol NavigatableTheme {
	associatedtype Language: Hashable
	associatedtype ID: Hashable

	var id: ID {get}
	var parent: ID? {get}
	var language: Language {get}
}

protocol SongRegistry {
	associatedtype Language
	associatedtype Song: NavigatbleSong where Song.Language == Language
	associatedtype Theme: NavigatableTheme where Theme.Language == Language

	var rootThemes: [Theme.ID] {get}

	func searchSong(_ text: String) -> [Song.ID]

	func rootThemes(in language: Language) -> [Theme]
	func subCategories(of theme: Theme.ID) -> [Theme.ID]
	func songs(in theme: Theme.ID) -> [Song]
	func translations(for song: Song.ID) -> [Song.ID]

//	func themeOf(song id: Song.ID) -> Theme
//	func languageOf(theme id: Theme.ID) -> Language
//	func languageOf(song id: Song.ID) -> Language

	subscript(song: Song.ID) -> Song? {get}
}

extension SongRegistry {
	func translation(for song: Song.ID, to language: Language) -> Song? {
		translatedSongId(for: song, to: language).flatMap {translatedID in self[translatedID]}
	}

	func translatedSongId(for song: Song.ID, to language: Language) -> Song.ID? {
		translations(for: song).first {self[$0]?.language == language}
	}
}

class BrowserState<Registry: SongRegistry>: ObservableObject {

	let registry: Registry

	@Published var themeLanguage: Registry.Language
	@Published var themes = [Registry.Theme]()
	@Published var songs = [Registry.Song]()

	@Published var selectedThemes = Set<Registry.Theme.ID>()
	@Published var selectedSongs = Set<Registry.Song.ID>()

	@Published var searchTerm = ""

	let songState: SongState<Registry>

	init(songs: Registry, language: Registry.Language) {
		registry = songs
		songState = SongState(registry: registry)
		themeLanguage = language
	}

}

class SongState<Registry: SongRegistry>: ObservableObject {
	private struct Selection {
		let  external : Registry.Song.ID
		var `internal`: Registry.Song

		init (song: Registry.Song) { (self.internal, external) = (song, song.id) }
	}

	let registry: Registry
	@Published private var selection: Selection?

	init(registry: Registry, song: Registry.Song? = nil) {
		self.registry = registry
		if let song = song {
			selection = Selection(song: song)
		} else {
			selection = nil
		}
	}

	var song: Registry.Song? { selection?.internal }
	var currentLanguage: Registry.Language? { selection?.internal.language }
	var availableLanguages: Set<Registry.Language> {
		guard let selection = selection else {return Set()}
		let translatedSongIDs = registry.translations(for: selection.external)
		return Set(translatedSongIDs.compactMap {registry[$0]?.language} )
	}

	func changeLanguage(to language: Registry.Language) throws {
		guard let sourceSongId = selection?.external else { throw Error.NoSongSelected }
		guard let translation = registry.translation(for: sourceSongId, to: language) else {
			throw Error.LanguageNotAvailable(language, sourceSongId)
		}

		selection!.internal = translation
	}

	func changeSong(to newSong: Registry.Song) {
		selection = Selection(song: newSong)
	}

	enum Error: Swift.Error {
		case LanguageNotAvailable(Registry.Language, Registry.Song.ID)
		case NoSongSelected
	}
}
