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

	enum GroupedTheme: Hashable {
		case group(String)
		case theme(Registry.Theme)
	}

	static func createLayout() -> UICollectionViewLayout {
		let configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
		let layout = UICollectionViewCompositionalLayout.list(using: configuration)

		return layout
	}

	static func createDataSource(for view: UICollectionView, with context: BrowserState<Registry>) -> UICollectionViewDiffableDataSource<Section, GroupedTheme> {
		let groupCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
			var content = cell.defaultContentConfiguration()
			content.text = item
			cell.contentConfiguration = content
			cell.accessories = [.outlineDisclosure()]
		}

		let themeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Registry.Theme> { cell, indexPath, item in
			var content = cell.defaultContentConfiguration()
			content.text = item.subtitle ?? item.title
			cell.contentConfiguration = content
		}

		let dataSource = UICollectionViewDiffableDataSource<Section, GroupedTheme>(collectionView: view) { (view: UICollectionView, index, theme) -> UICollectionViewCell? in

			switch theme {
			case .group(let title): return view.dequeueConfiguredReusableCell(using: groupCellRegistration, for: index, item: title)
			case .theme(let theme): return view.dequeueConfiguredReusableCell(using: themeCellRegistration, for: index, item: theme)
			}
		}

		var initialData = NSDiffableDataSourceSnapshot<Section, GroupedTheme>()
		initialData.appendSections([.main])
		dataSource.apply(initialData, animatingDifferences: false)

		var initialSectionData = NSDiffableDataSourceSectionSnapshot<GroupedTheme>()
		for themeGroup in context.themes {
			if themeGroup.count > 1 {
				let root = GroupedTheme.group(themeGroup.first!.title)
				initialSectionData.append([root])
				initialSectionData.append(themeGroup.map{.theme($0)}, to: root)
			} else {
				initialSectionData.append(themeGroup.map{.theme($0)})
			}
		}
		dataSource.apply(initialSectionData, to: .main, animatingDifferences: false)

		return dataSource
	}
}
