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
		let subtitle: String?

		let id: Tagged<Theme, Int>
		let language: Language
	}

	struct Song: ReferableSong {
		let title: String

		let id: Tagged<Song, Int>
		let language: Language
		let originalVersion: Tagged<Song, Int>?
	}

	struct Theme🔗Songs {
		let songID: Song.ID
		let themeID: Theme.ID
	}

	// Raw Data
	let songs: [Song]
	let themes: [Theme]
	let theme🔗songs: [Theme🔗Songs]

	// Indices
	private let index: Index

	init(songs: [Song] = [], themes: [Theme] = [], theme🔗songs: [Theme🔗Songs] = []) {
		self.songs = songs
		self.themes = themes
		self.theme🔗songs = theme🔗songs
		index = Index(songs: songs, themes: themes, theme🔗songs: theme🔗songs)
	}

	func searchSong(_ text: String) -> [Song.ID] {
		return songs.lazy.filter { $0.title.contains(text) }.map(\.id)
	}

	func groupedThemes(in language: Language) -> [[Theme]] {
		var groups = [String: [Theme]]()
		for theme in themes {
			if theme.language == language {
				if groups.keys.contains(theme.title) { groups[theme.title]!.append(theme) }
				else { groups[theme.title] = [theme]}
			}
		}
		return Array(groups.values)
	}

	func themeOf(song id: Song.ID) -> Theme {
		themes[index.themesBySong[id.rawValue].rawValue]
	}

	func songs(in theme: Theme.ID) -> [Song] {
		index.songsByTheme[theme.rawValue].map{songs[$0.rawValue]}
	}

	func translations(for song: Song.ID) -> [Song.ID] {
		let original = songs[song.rawValue].originalVersion ?? song
		return [original] + (index.songsByOriginalSong[original] ?? [])
	}

	subscript(song: Song.ID) -> Song? { songs[song.rawValue] }
	subscript(theme: Theme.ID) -> Theme? { themes[theme.rawValue] }
}

extension MemoryDataBase {
	struct Index {
		let themesByLanguage: [[Theme.ID]]
		let themesBySong: [Theme.ID]
		let songsByTheme: [[Song.ID]]
		let songsByOriginalSong: [Song.ID: [Song.ID]]

		init(songs: [Song], themes: [Theme], theme🔗songs: [Theme🔗Songs]) {
			songsByTheme = group(theme🔗songs, grouping: \.themeID, target: \.songID)
			themesByLanguage =  group(themes, grouping: \.language, target: \.id)
			songsByOriginalSong = group(songs, grouping: \.originalVersion, key: \.id)
			var tempThemesBySong = [Theme.ID](repeating: .zero, count: songs.count)
			for (theme, songs) in songsByTheme.enumerated() {
				for song in songs {
					tempThemesBySong[song.rawValue] = .init(rawValue: theme)
				}
			}
			themesBySong = tempThemesBySong
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
		.init(title: "Wij begroeten U", id: 0, language: .Dutch, originalVersion: 3),
		.init(title: "Nu ik sta voor uw aangezicht", id: 1, language: .Dutch, originalVersion: nil),
		.init(title: "Hail Queen of Heaven", id: 2, language: .English, originalVersion: 3),
		.init(title: "Couronné d'étoiles", id: 3, language: .French, originalVersion: nil),
		.init(title: "Wees gegroet Maria", id: 4, language: .Dutch, originalVersion: nil),
	],
	themes: [
		.init(title: "Marialiedjes", subtitle: nil, id: 0, language: .Dutch),
		.init(title: "Marian songs", subtitle: nil, id: 1, language: .English),
		.init(title: "Divers", subtitle: nil, id: 2, language: .Dutch),
		.init(title: "Divers", subtitle: "Dinges", id: 3, language: .Dutch),
		.init(title: "Marie", subtitle: nil, id: 4, language: .French),
	],
	theme🔗songs: [
		.init(songID: 0, themeID: 0),
		.init(songID: 1, themeID: 3),
		.init(songID: 2, themeID: 1),
		.init(songID: 3, themeID: 4),
		.init(songID: 4, themeID: 0),
	]
)
