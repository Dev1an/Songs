//
//  Songs.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit
import Combine

class SongsController<Registry: PresentableSongRegistry>: CollectionController<SongsController> {
	let searchController = UISearchController(searchResultsController: nil)
	var selectionObserver: AnyCancellable?
	var contentObserver: AnyCancellable?

	override func configureCollection() {
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		navigationItem.title = "Songs"

		selectionObserver = context.$selectedSongs.sink { [unowned self] selection in
			for songID in selection {
				let song = context.registry[songID]!
				let path = collection.data.indexPath(for: song)
				collection.view.selectItem(at: path, animated: false, scrollPosition: .top)
			}
		}

		contentObserver = context.$songs.sink { [unowned self] songs in
			var newData = NSDiffableDataSourceSnapshot<Section, Registry.Song>()
			newData.appendSections([.main])
			newData.appendItems(songs)

			let lessThan70Changes = collection.data.snapshot().numberOfItems - newData.numberOfItems < 70

			collection.data.apply(newData, animatingDifferences: lessThan70Changes)
		}
	}
}
