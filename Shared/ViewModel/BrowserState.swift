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

	@Published var searchTerm = "" { willSet {updateDependencies(for: newValue)} }
	@Published var isSearching = false { willSet {updateDependencies(for: newValue)} }
	@Published var searchScope = SearchScope<Registry.Theme.ID>.all { willSet {updateDependencies(for: searchTerm, scope: newValue)} }

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
		if isSearching == false {
			showAllSongs(in: selectedThemes)
		}
	}

	func updateDependencies(for searchTerm: String, scope: SearchScope<Registry.Theme.ID>? = nil) {
		let scope = scope ?? searchScope
		if searchTerm.count > 2 {
			songs = registry.searchSong(searchTerm, in: scope).compactMap{ registry[$0] }
		} else {
			switch scope {
			case .all: songs = registry.songs
			case .theme(let theme): showAllSongs(in: [theme])
			}
		}
	}

	func updateDependencies(for searchState: Bool) {
		if searchState == false {
			showAllSongs(in: selectedThemes)
		} else {
			updateDependencies(for: searchTerm)
		}
	}

	func showAllSongs(in themes: Set<Registry.Theme.ID>) {
		songs = registry.songs(in: themes)
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
