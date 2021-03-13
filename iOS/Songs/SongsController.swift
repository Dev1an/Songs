//
//  Songs.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit
import Combine

class SongsController<Registry: PresentableSongRegistry>: CollectionController<SongsController>, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, UICollectionViewDelegate {

	let searchController = UISearchController(searchResultsController: nil)
	var selectionObserver: AnyCancellable?
	var contentObserver: AnyCancellable?
	var themeObserver: AnyCancellable?

	override func configureCollection() {
		collection.view.delegate = self
		setupSearchBar()
		navigationItem.title = "Songs"

		themeObserver = context.$selectedThemes.sink { [unowned self] selection in
			if selection.count == 1, let theme = context.registry[selection.first!] {
				navigationItem.title = theme.subtitle ?? theme.title
			} else {
				navigationItem.title = "Songs"
			}
			updateSearchScopeOptions(selection: selection)
		}

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

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let song = collection.data.itemIdentifier(for: indexPath) {
			context.selectedSongs = [song.id]
			// TODO: navigate to song on compact width devices
//			delegate?.navigateToTheme()
		} else {
			fatalError("Song not found")
		}

	}

	// MARK: Search bar

	func setupSearchBar() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchResultsUpdater = self
		searchController.delegate = self
		searchController.searchBar.delegate = self
		searchController.view.layer.zPosition = collection.view.layer.zPosition + 1
		navigationItem.searchController = searchController
	}

	func updateSearchResults(for searchController: UISearchController) {
		if let searchTerm = searchController.searchBar.text {
			context.searchTerm = searchTerm
		}
	}

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		print("scope", selectedScope)
	}

	func updateSearchScopeOptions(selection: Set<Registry.Theme.ID>) {
		let themeNames: [String] = selection.compactMap { id in
			guard let theme = context.registry[id] else { return nil }
			return theme.subtitle ?? theme.title
		}
		let allSongs = NSLocalizedString("All songs", comment: "Search scope to searhc in all the songs")
		searchController.searchBar.scopeButtonTitles = themeNames.isEmpty ? nil : [allSongs] + themeNames
	}

	func willPresentSearchController(_ searchController: UISearchController) {
		let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
		// TODO: Add animation
		collection.view.setCollectionViewLayout(UICollectionViewCompositionalLayout.list(using: configuration), animated: false)
		backgroundColorFix()
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		// TODO: Add animation
		collection.view.setCollectionViewLayout(Self.createLayout(), animated: false)
		backgroundColorFix()
	}

	// TODO: remove this bugfix
	func backgroundColorFix() {
		if traitCollection.userInterfaceStyle != .dark {
			let selection = context.selectedSongs.compactMap{context.registry[$0]}
			if !selection.isEmpty {
				var snapshot = collection.data.snapshot()
				snapshot.reloadItems(selection)
				collection.data.apply(snapshot)
				for path in selection.compactMap({collection.data.indexPath(for: $0)}) {
					collection.view.selectItem(at: path, animated: false, scrollPosition: [])
				}
			} else {
				print("selection was empty", context.selectedSongs, selection)
			}
		}
	}
}
