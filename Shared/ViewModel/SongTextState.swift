//
//  SongTextState.swift
//  Songs
//
//  Created by Damiaan on 11/03/2021.
//

import SwiftUI

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
