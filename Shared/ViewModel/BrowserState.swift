//
//  BrowserState.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 08/03/2021.
//

import SwiftUI

class BrowserState<Registry: SongRegistry>: ObservableObject {

	let registry: Registry

	@Published var themeLanguage: Registry.Language
	@Published var themes: [[Registry.Theme]]
	@Published var songs: [Registry.Song]

	@Published var selectedThemes: Set<Registry.Theme.ID>
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
