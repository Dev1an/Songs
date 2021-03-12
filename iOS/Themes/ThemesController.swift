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
				if theme.subtitle != nil {
					var snapshot = collection.data.snapshot(for: .main)
					let parent = GroupedTheme.group(theme.title)
					if !snapshot.isExpanded(parent) {
						snapshot.expand([parent])
						// TODO: file bug report for text highlight when animating
						collection.data.apply(snapshot, to: .main, animatingDifferences: false)
					}
				}
				let path = collection.data.indexPath(for: .theme(theme))
				collection.view.selectItem(at: path, animated: false, scrollPosition: .top)
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if case .theme(let theme) = collection.data.itemIdentifier(for: indexPath) {
			context.selectedThemes = [theme.id]
		} else {
			fatalError("Should not be able to select groups")
		}
	}

	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		if let item = collection.data.itemIdentifier(for: indexPath) {
			if case .theme(_) = item {
				return true
			} else {
				var snapshot = collection.data.snapshot(for: .main)
				if snapshot.isExpanded(item) { snapshot.collapse([item]) }
				else { snapshot.expand([item]) }
				collection.data.apply(snapshot, to: .main, animatingDifferences: true)
				return false
			}
		} else {
			return false
		}
	}

}
