//
//  SongsDataSource.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

extension SongsController: CollectionPropertiesProvider {
	enum Section {
		case main
	}

	static func createLayout() -> UICollectionViewLayout {
		let configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)

		return layout
	}

	static func createDataSource(for view: UICollectionView, with context: BrowserState<Registry>) -> UICollectionViewDiffableDataSource<Section, Registry.Song> {
		let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Registry.Song> { cell, indexPath, item in
			var content = cell.defaultContentConfiguration()
			content.text = item.title
			content.secondaryText = "song text"
			cell.accessories = [.label(text: "01-43-NL")]
			cell.contentConfiguration = content
		}

		let dataSource = UICollectionViewDiffableDataSource<Section, Registry.Song>(collectionView: view) { (view: UICollectionView, index, song) -> UICollectionViewCell? in
			view.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: song)
		}

		var initialData = NSDiffableDataSourceSnapshot<Section, Registry.Song>()
		initialData.appendSections([.main])
		initialData.appendItems(context.songs)

		dataSource.apply(initialData, animatingDifferences: false)

		return dataSource
	}
}

