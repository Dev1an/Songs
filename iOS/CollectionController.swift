//
//  CollectionController.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

class CollectionController<Provider: CollectionPropertiesProvider>: UIViewController {

	typealias DataSource = UICollectionViewDiffableDataSource<Provider.Section, Provider.Item>

	struct CollectionProperties {
		let view: UICollectionView
		let data: DataSource

		init(with context: Provider.Context) {
			view = UICollectionView(frame: .zero, collectionViewLayout: Provider.createLayout())
			data = Provider.createDataSource(for: view, with: context)
		}
	}

	let context: Provider.Context
	let collection: CollectionProperties

	init(context: Provider.Context) {
		self.context = context
		collection = CollectionProperties(with: context)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has is not supported")
	}

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
	associatedtype Context
	associatedtype Section: Hashable
	associatedtype Item: Hashable

	static func createLayout() -> UICollectionViewLayout
	static func createDataSource(for view: UICollectionView, with context: Context) -> UICollectionViewDiffableDataSource<Section, Item>
}
