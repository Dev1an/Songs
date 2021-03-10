//
//  MemoryDB.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 09/03/2021.
//

import Tagged

class MemoryDataBase: SongRegistry {

	enum Language: UInt8 {
		case Dutch, English, French
	}

	struct Theme: NavigatableTheme {
		let title: String

		let id: Tagged<Theme, Int>
		let parent: Tagged<Theme, Int>?
		let language: MemoryDataBase.Language
	}

	struct Song: NavigatbleSong {
		let title: String

		let id: Tagged<Song, Int>
		let language: MemoryDataBase.Language
		let originalVersion: ID?
		let theme: Theme.ID
	}

	// Raw Data
	let songs: [Song]
	let themes: [Theme]

	// Indices
	private let index: Index
	var rootThemes: [Theme.ID] { index.rootThemes }

	init(songs: [Song] = [], themes: [Theme] = []) {
		self.songs = songs
		self.themes = themes
		index = Index(songs: songs, themes: themes)
	}

	func searchSong(_ text: String) -> [Song.ID] {
		return songs.lazy.filter { $0.title.contains(text) }.map(\.id)
	}

	func rootThemes(in language: Language) -> [Theme] {
		index.rootThemes.filter { themes[$0.rawValue].language == language }.map {themes[$0.rawValue]}
	}

	func subCategories(of theme: Theme.ID) -> [Theme.ID] {
		index.themesByParent[theme] ?? []
	}

	func songs(in theme: Theme.ID) -> [Song] {
		index.songsByTheme[theme.rawValue].map{songs[$0.rawValue]}
	}

	func translations(for song: Song.ID) -> [Song.ID] {
		let original = songs[song.rawValue].originalVersion ?? song
		return [original] + (index.songsByOriginalSong[original] ?? [])
	}

	subscript(song: Song.ID) -> Song? {
		songs[song.rawValue]
	}
}

extension MemoryDataBase {
	struct Index {
		let rootThemes: [Theme.ID]
		let rootThemesByLanguage: [[Theme.ID]]
		let songsByTheme: [[Song.ID]]
		let themesByParent: [Theme.ID: [Theme.ID]]
		let songsByOriginalSong: [Song.ID: [Song.ID]]

		init(songs: [Song], themes: [Theme]) {
			rootThemes = themes.filter { theme in theme.parent == nil }.map(\.id)
			rootThemesByLanguage = group(rootThemes.map{themes[$0.rawValue]}, grouping: \.language, target: \.id)
			themesByParent = group(themes, grouping: \.parent, key: \.id)
			songsByOriginalSong = group(songs, grouping: \.originalVersion, key: \.id)
			songsByTheme = group(songs, grouping: \.theme, target: \.id)
		}
	}
}

extension MemoryDataBase.Theme: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (left: Self, right: Self) -> Bool {
		left.id == right.id
	}
}

func group<Value, Key>(_ values: [Value], grouping: (KeyPath<Value, Key?>), key: KeyPath<Value,Key>) -> [Key: [Key]] {
	var groups = [Key : [Key]]()
	for value in values {
		if let group = value[keyPath: grouping] {
			if groups.keys.contains(group) { groups[group]!.append(value[keyPath: key]) }
			else { groups[group] = [value[keyPath: key]] }
		}
	}
	return groups
}

func group<Value, Group: RawRepresentable, Target>(_ values: [Value], grouping: (KeyPath<Value, Group>), target: KeyPath<Value,Target>) -> [[Target]] where Group.RawValue: FixedWidthInteger, Group: Hashable {
	var groups = [Group : [Target]]()
	for value in values {
		let group = value[keyPath: grouping]
		if groups.keys.contains(group) { groups[group]!.append(value[keyPath: target]) }
		else { groups[group] = [value[keyPath: target]] }
	}
	for key in 0..<Group.RawValue(groups.count) {
		let typedKey = Group(rawValue: key)!
		if !groups.keys.contains(typedKey) {groups[typedKey] = []}
	}
	let compact = groups.sorted {$0.key.rawValue < $1.key.rawValue}
	return compact.map(\.value)
}

let sampleData = MemoryDataBase(
	songs: [
		.init(title: "Wij begroeten U", id: 0, language: .Dutch, originalVersion: 3, theme: 0),
		.init(title: "Nu ik sta voor uw aangezicht", id: 1, language: .Dutch, originalVersion: nil, theme: 3),
		.init(title: "Hail Queen of Heaven", id: 2, language: .English, originalVersion: 3, theme: 1),
		.init(title: "Couronné d'étoiles", id: 3, language: .French, originalVersion: nil, theme: 4),
		.init(title: "Wees gegroet Maria", id: 4, language: .Dutch, originalVersion: nil, theme: 0),
	],
	themes: [
		.init(title: "Marialiedjes", id: 0, parent: nil, language: .Dutch),
		.init(title: "Maria songs", id: 1, parent: nil, language: .English),
		.init(title: "Divers", id: 2, parent: nil, language: .Dutch),
		.init(title: "Dinges", id: 3, parent: 2, language: .Dutch),
		.init(title: "Marie", id: 4, parent: nil, language: .French),
	]
)
