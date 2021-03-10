//
//  CollectionController.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

class CollectionController<Provider: CollectionPropertiesProvider>: UIViewController {
	struct CollectionProperties<Section: Hashable, Item: Hashable> {
		let view: UICollectionView
		let data: UICollectionViewDiffableDataSource<Section, Item>

		init<P: CollectionPropertiesProvider>(provider: P.Type) where P.Section == Section, P.Item == Item {
			view = UICollectionView(frame: .zero, collectionViewLayout: provider.createLayout())
			data = provider.createDataSource(for: view)
		}
	}

	let collection = CollectionProperties(provider: Provider.self)

	override func viewDidLoad() {
		super.viewDidLoad()
		collection.view.frame = view.bounds
		collection.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		configureCollection()
		view.addSubview(collection.view)
	}

	func configureCollection() {}
}

protocol CollectionPropertiesProvider {
	associatedtype Section: Hashable
	associatedtype Item: Hashable

	static func createLayout() -> UICollectionViewLayout
	static func createDataSource(for view: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item>
}
