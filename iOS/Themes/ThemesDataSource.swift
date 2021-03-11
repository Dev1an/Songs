//
//  ThemesDataSource.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

extension ThemeController: CollectionPropertiesProvider {
	enum Section {
		case main
	}

	static func createLayout() -> UICollectionViewLayout {
		let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)

		return layout
	}

	static func createDataSource(for view: UICollectionView, with context: BrowserState<Registry>) -> UICollectionViewDiffableDataSource<Section, Registry.Theme> {
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Registry.Theme> { cell, indexPath, item in
			var content = cell.defaultContentConfiguration()
			content.text = item.title
			cell.contentConfiguration = content
		}

		let dataSource = UICollectionViewDiffableDataSource<Section, Registry.Theme>(collectionView: view) { (view: UICollectionView, index, themeID) -> UICollectionViewCell? in
			view.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: themeID)
		}

		var initialData = NSDiffableDataSourceSnapshot<Section, Registry.Theme>()
		initialData.appendSections([.main])
		initialData.appendItems(context.themes.flatMap{$0})

		dataSource.apply(initialData, animatingDifferences: false)

		return dataSource
	}
}
