//
//  ThemeColumn.swift
//  Songs (iOS)
//
//  Created by Damiaan on 09/03/2021.
//

import UIKit

class ThemeController<Registry: SongRegistry>: CollectionController<ThemeController>, UICollectionViewDelegate {

	override func configureCollection() {
		collection.view.delegate = self
		navigationItem.title = "Themes"
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(indexPath)
	}
}
