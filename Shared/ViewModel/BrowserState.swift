//
//  BrowserState.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 08/03/2021.
//

import SwiftUI

class BrowserState<Registry: SongRegistry>: ObservableObject {

	let registry: Registry

	@Published private (set) var languages: [Registry.Language]
	@Published private (set) var themes: [[Registry.Theme]] { willSet {updateDependencies(for: newValue)} }
	@Published private (set) var songs: [Registry.Song]

	@Published var selectedLanguage: Registry.Language { willSet {updateDependencies(for: newValue)} }
	@Published var selectedThemes: Set<Registry.Theme.ID> { willSet {updateDependencies(for: newValue)} }
	@Published var selectedSongs = Set<Registry.Song.ID>()

	@Published var searchTerm = "" { willSet {filterSongs(by: newValue)} }
	@Published var isSearching = false { willSet {update(searchState: newValue)} }
	@Published var searchScope = SearchScope<Registry.Theme.ID>.all { willSet {filterSongs(by: searchTerm)} }

	let songState: SongState<Registry>

	init(songs: Registry, language: Registry.Language) {
		registry = songs
		songState = SongState(registry: registry)
		selectedLanguage = language
		languages = songs.languages
		let groupedThemes = registry.groupedThemes(in: language)
		themes = groupedThemes

		if let theme = groupedThemes.first?.first {
			let selection: Set = [theme.id]
			selectedThemes = selection
			self.songs = songs.songs(in: selection)
		} else {
			self.songs = []
			selectedThemes = []
		}
	}

	private func updateDependencies(for selectedLanguage: Registry.Language) {
		themes = registry.groupedThemes(in: selectedLanguage)
	}

	private func updateDependencies(for visibleThemes: [[Registry.Theme]]) {
		if !selectedThemesAreContained(in: visibleThemes) {
			selectedThemes = []
		}
	}

	private func updateDependencies(for selectedThemes: Set<Registry.Theme.ID>) {
		if isSearching {
			filterSongs(by: searchTerm)
		} else {
			songs = registry.songs(in: selectedThemes)
		}
	}

	func filterSongs(by searchTerm: String) {
		if searchTerm.count > 2 {
			songs = registry.searchSong(searchTerm, in: searchScope).compactMap{ registry[$0] }
		} else {
			songs = (searchScope == .all) ? registry.songs : registry.songs(in: selectedThemes)
		}
	}

	func update(searchState: Bool) {
		if searchState == false {
			updateDependencies(for: selectedThemes)
		}
	}

	func selectedThemesAreContained(in groups: [[Registry.Theme]]) -> Bool {
		var themesToCheck = selectedThemes
		for group in groups {
			for theme in group {
				themesToCheck.remove(theme.id)
			}
			// Early exit
			if themesToCheck.isEmpty { return true}
		}
		return themesToCheck.isEmpty
	}
}
