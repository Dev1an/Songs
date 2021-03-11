//
//  ThemeColumn.swift
//  Songs (iOS)
//
//  Created by Damiaan on 09/03/2021.
//

import UIKit
import Combine

class ThemeController<Registry: SongRegistry>: CollectionController<ThemeController>, UICollectionViewDelegate {

	var selectionObserver: AnyCancellable?

	override func configureCollection() {
		collection.view.delegate = self
		navigationItem.title = "Themes"

		selectionObserver = context.$selectedThemes.sink { [unowned self] selection in
			for themeID in selection {
				let theme = context.registry[themeID]!
				let path = collection.data.indexPath(for: theme)
				collection.view.selectItem(at: path, animated: false, scrollPosition: .top)
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let theme = collection.data.itemIdentifier(for: indexPath) {
			context.selectedThemes = [theme.id]
		}
	}
}
