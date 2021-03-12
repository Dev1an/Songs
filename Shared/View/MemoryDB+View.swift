//
//  MemoryDB+View.swift
//  Songs (iOS)
//
//  Created by Damiaan on 12/03/2021.
//

extension MemoryDataBase.Song: PresentableSong {}
extension MemoryDataBase.Theme: PresentableTheme {}
extension MemoryDataBase.Language: PresentableLanguage {
	var code: String { rawValue }
}
extension MemoryDataBase: PresentableSongRegistry {}
