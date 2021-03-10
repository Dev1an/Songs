//
//  SongsDataSource.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

extension SongsController: CollectionPropertiesProvider {
	static func createLayout() -> UICollectionViewLayout {
		let configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)

		return layout
	}

	static func createDataSource(for view: UICollectionView, with context: BrowserState<Registry>) -> UICollectionViewDiffableDataSource<ThemeController<Registry>.Section, Registry.Theme> {
		ThemeController<Registry>.createDataSource(for: view, with: context)
	}
}

