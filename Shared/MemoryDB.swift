//
//  MemoryDB.swift
//  EmmaSongs Explorer
//
//  Created by Damiaan on 09/03/2021.
//

import Tagged

class MemoryDataBase: SongRegistry {
	typealias LocalScope = SearchScope<Theme.ID>

	enum Language: String, CaseIterable {
		case dutch = "nl", english = "en", french = "fr"
	}

	struct Theme: ReferableTheme {
		let title: String
		let subtitle: String?

		let id: Tagged<Theme, Int>
		let language: Language
	}

	struct Song: ReferableSong {
		typealias ID = Tagged<Song, Int>
		let title: String

		let id: ID
		let language: Language
		let originalVersion: ID?
	}

	struct Theme🔗Songs {
		let songID: Song.ID
		let themeID: Theme.ID
	}

	// Raw Data
	let songs: [Song]
	let themes: [Theme.ID: Theme]

	// Indices
	private let index: Index

	init(songs: [Song] = [], themes: [Theme] = [], theme🔗songs: [Theme🔗Songs] = []) {
		self.songs = songs
		self.themes = Dictionary(uniqueKeysWithValues: themes.map{($0.id, $0)})
		index = Index(songs: songs, themes: themes, theme🔗songs: theme🔗songs)
	}

	func searchSong(_ text: String, in scope: LocalScope) -> [Song.ID] {
		let allSongs = songs.lazy.filter { $0.title.contains(text) }
		switch scope {
		case .all: return allSongs.map(\.id)
		case .theme(let theme): return allSongs.filter{ self.index.themesBySong[$0.id.rawValue] == theme }.map(\.id)
		}
	}

	func groupedThemes(in language: Language) -> [[Theme]] {
		var groups = [String: [Theme]]()
		guard let themes = index.themesByLanguage[language]?.map({themes[$0]!}) else { return [] }
		for theme in themes {
			if groups.keys.contains(theme.title) { groups[theme.title]!.append(theme) }
			else { groups[theme.title] = [theme]}
		}
		return Array(groups.values)
	}

	func themeOf(song id: Song.ID) -> Theme {
		// TODO typeCheck
		themes[index.themesBySong[id.rawValue]]!
	}

	func songs<Themes: Collection>(in themes: Themes) -> [Song] where Themes.Element == Theme.ID {
		var result = Set<Song.ID>()
		for theme in themes {
			result = result.union(index.songsByTheme[theme.rawValue])
		}
		return result.map{songs[$0.rawValue]}
	}

	func translations(for song: Song.ID) -> [Song.ID] {
		let original = songs[song.rawValue].originalVersion ?? song
		return [original] + (index.songsByOriginalSong[original] ?? [])
	}

	subscript(song: Song.ID) -> Song? { songs[song.rawValue] }
	subscript(theme: Theme.ID) -> Theme? { themes[theme] }
}

extension MemoryDataBase {
	struct Index {
		let themesByLanguage: [Language: [Theme.ID]]
		let themesBySong: [Theme.ID]
		let songsByTheme: [[Song.ID]]
		let songsByOriginalSong: [Song.ID: [Song.ID]]

		init(songs: [Song], themes: [Theme], theme🔗songs: [Theme🔗Songs]) {
			songsByTheme = group(theme🔗songs, grouping: \.themeID, target: \.songID)
			themesByLanguage = group(themes, groupBy: \.language, target: \.id)
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

	var languages: [Language] { Language.allCases }
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

func group<Value, Group, Target>(_ values: [Value], groupBy grouping: KeyPath<Value, Group>, target: KeyPath<Value, Target>) -> [Group: [Target]] {
	var groups = [Group : [Target]]()
	for value in values {
		let group = value[keyPath: grouping]
		let target = value[keyPath: target]
		if groups.keys.contains(group) { groups[group]!.append(target) }
		else { groups[group] = [target] }
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

let dongesID = MemoryDataBase.Theme.ID(2)
let sampleData = MemoryDataBase(
	songs: [
		.init(title: "Wij begroeten U", id: 0, language: .dutch, originalVersion: 3),
		.init(title: "Nu ik sta voor uw aangezicht", id: 1, language: .dutch, originalVersion: nil),
		.init(title: "Hail Queen of Heaven", id: 2, language: .english, originalVersion: 3),
		.init(title: "Couronné d'étoiles", id: 3, language: .french, originalVersion: nil),
		.init(title: "Wees gegroet Maria", id: 4, language: .dutch, originalVersion: nil),
	],
	themes: [
		.init(title: "Marialiedjes", subtitle: nil, id: 0, language: .dutch),
		.init(title: "Marian songs", subtitle: nil, id: 1, language: .english),
		.init(title: "Divers", subtitle: "Donges", id: dongesID, language: .dutch),
		.init(title: "Divers", subtitle: "Dinges", id: 3, language: .dutch),
		.init(title: "Marie", subtitle: nil, id: 4, language: .french),
	],
	theme🔗songs: [
		.init(songID: 0, themeID: 0),
		.init(songID: 1, themeID: 3),
		.init(songID: 2, themeID: 1),
		.init(songID: 3, themeID: 4),
		.init(songID: 4, themeID: 0),
	]
)
