//
//  ThemesDataSource.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

extension ThemeController: CollectionPropertiesProvider {
	static func createLayout() -> UICollectionViewLayout {
		let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)

		return layout
	}

	static func createDataSource(for view: UICollectionView) -> UICollectionViewDiffableDataSource<MemoryDataBase.Theme.ID, MemoryDataBase.Theme> {
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, MemoryDataBase.Theme> { cell, indexPath, item in
			var content = cell.defaultContentConfiguration()
			content.text = item.title
			cell.contentConfiguration = content
		}

		let dataSource = UICollectionViewDiffableDataSource<MemoryDataBase.Theme.ID, MemoryDataBase.Theme>(collectionView: view) { (view: UICollectionView, index, themeID) -> UICollectionViewCell? in
			view.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: themeID)
		}

		var initialData = NSDiffableDataSourceSnapshot<MemoryDataBase.Theme.ID, MemoryDataBase.Theme>()
		initialData.appendSections([0])
		initialData.appendItems(sampleData.rootThemes(in: .Dutch))

		dataSource.apply(initialData, animatingDifferences: false)

		return dataSource
	}
}
