//
//  ThreeColumnView.swift
//  Songs (iOS)
//
//  Created by Damiaan Dufaux on 09/03/2021.
//

import SwiftUI

final class ThreeColumnView<C: View, Registry: SongRegistry>: UIViewControllerRepresentable {
	let stateManager: BrowserState<Registry>
	let primaryController, supplementaryController, secondaryController: UINavigationController

	init(stateManager: BrowserState<Registry>, secondaryContent: C) {
		self.stateManager = stateManager
		let themeController = ThemeController(context: stateManager)
		let songsController = SongsController(context: stateManager)
		primaryController = UINavigationController(rootViewController: themeController)
		secondaryController = host(secondaryContent)
		supplementaryController = UINavigationController(rootViewController: songsController)
	}
	
	func makeUIViewController(context: Context) -> UISplitViewController {
		let split = UISplitViewController(style: .tripleColumn)
		split.setViewController(primaryController, for: .primary)
		split.setViewController(secondaryController, for: .secondary)
		split.setViewController(supplementaryController, for: .supplementary)
		
		primaryController.navigationBar.prefersLargeTitles = true
		supplementaryController.navigationBar.prefersLargeTitles = true
		split.preferredSplitBehavior = .tile
		return split
	}
	
	func updateUIViewController(_ uiViewController: UISplitViewController, context: Context) {
		
	}
}

func host<V: View>(_ view: V, title: String? = nil, configurator: (UIHostingController<V>)->Void = {_ in}) -> UINavigationController {
	let controller = UIHostingController(rootView: view)
	controller.title = title
	configurator(controller)
	return UINavigationController(rootViewController: controller)
}

struct ThreeColumnView_Previews: PreviewProvider {
	static var previews: some View {
		ThreeColumnView(stateManager: BrowserState(songs: sampleData, language: .Dutch), secondaryContent: Text("This is me"))
	}
}
