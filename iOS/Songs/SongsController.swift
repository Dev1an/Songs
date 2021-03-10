//
//  Songs.swift
//  Songs (iOS)
//
//  Created by Damiaan on 10/03/2021.
//

import UIKit

class SongsController: CollectionController<SongsController> {
	let searchController = UISearchController(searchResultsController: nil)

	override func configureCollection() {
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
		navigationItem.title = "Songs"
	}
}
