//
//  ThemeColumn.swift
//  Songs (iOS)
//
//  Created by Damiaan on 09/03/2021.
//

import UIKit

class ThemeController: CollectionController<ThemeController> {
	override func configureCollection() {
		collection.view.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Themes"
	}
}

extension ThemeController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(indexPath)
	}
}
