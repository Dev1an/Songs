//
//  LanguageMenu.swift
//  Songs (iOS)
//
//  Created by Damiaan on 12/03/2021.
//

import SwiftUI

struct LanguageMenu: View {
	@Binding var selectedLanguage: String
	var languages: [String]

    var body: some View {
		Menu("Languages") {
			ForEach(languages, id: \.self) { language in
				languageButton(forLanguageCode: language)
			}
		}
    }

	func languageButton(forLanguageCode language: String) -> some View {
		Toggle(
			Locale.current.localizedString(forLanguageCode: language)!,
			isOn: Binding {language == selectedLanguage} set: {_ in selectedLanguage = language }
		)
	}
}

struct LanguageMenu_Previews: PreviewProvider {

	struct Example: View {
		@State var selection = "nl"
		var body: some View {
			LanguageMenu(selectedLanguage: $selection, languages: ["nl", "en", "fr"])
		}
	}

    static var previews: some View {
		Example()
    }
}
