//
//  ViewRequirements.swift
//  Songs (iOS)
//
//  Created by Damiaan on 12/03/2021.
//

protocol PresentableSongRegistry: SongRegistry where Song: PresentableSong, Theme: PresentableTheme, Language: PresentableLanguage {}

protocol PresentableLanguage {
	var code: String {get}
}

protocol PresentableSong {
	var title: String {get}
}

protocol PresentableTheme {
	var title: String {get}
	var subtitle: String? {get}
}
