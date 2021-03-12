//
//  BrowserState.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 08/03/2021.
//

import SwiftUI

class BrowserState<Registry: SongRegistry>: ObservableObject {

	let registry: Registry

	@Published private (set) var themeLanguage: Registry.Language
	@Published private (set) var themes: [[Registry.Theme]]
	@Published private (set) var songs: [Registry.Song]

	@Published var selectedThemes: Set<Registry.Theme.ID> {
		willSet {
			var newSongs = [Registry.Song]()
			for theme in newValue {
				newSongs.append(contentsOf: registry.songs(in: theme))
			}
			songs = newSongs
		}
	}
	@Published var selectedSongs = Set<Registry.Song.ID>()

	@Published var searchTerm = ""

	let songState: SongState<Registry>

	init(songs: Registry, language: Registry.Language) {
		registry = songs
		songState = SongState(registry: registry)
		themeLanguage = language
		let groupedThemes = registry.groupedThemes(in: language)
		themes = groupedThemes
		if let theme = groupedThemes.first?.first {
			selectedThemes = [theme.id]
			self.songs = songs.songs(in: theme.id)
		} else {
			self.songs = []
			selectedThemes = []
		}
	}

	
}
