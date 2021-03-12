//
//  ThreeColumnView.swift
//  Songs (iOS)
//
//  Created by Damiaan Dufaux on 09/03/2021.
//

import SwiftUI

final class ThreeColumnView<C: View, Registry: SongRegistry>: UIViewControllerRepresentable {
	let stateManager: BrowserState<Registry>
	let split = UISplitViewController(style: .tripleColumn)
	let primaryController, supplementaryController, secondaryController: UINavigationController
	let themeController: ThemeController<Registry>

	init(stateManager: BrowserState<Registry>, secondaryContent: C) {
		self.stateManager = stateManager
		themeController = ThemeController(context: stateManager)
		let songsController = SongsController(context: stateManager)
		primaryController = UINavigationController(rootViewController: themeController)
		secondaryController = host(secondaryContent)
		supplementaryController = UINavigationController(rootViewController: songsController)
	}
	
	func makeUIViewController(context: Context) -> UISplitViewController {
		split.setViewController(primaryController, for: .primary)
		split.setViewController(secondaryController, for: .secondary)
		split.setViewController(supplementaryController, for: .supplementary)
		themeController.delegate = self
		
		primaryController.navigationBar.prefersLargeTitles = true
		supplementaryController.navigationBar.prefersLargeTitles = true
		split.preferredSplitBehavior = .tile
		return split
	}
	
	func updateUIViewController(_ uiViewController: UISplitViewController, context: Context) {
		
	}
}

extension ThreeColumnView: ThemeControllerDelegate {
	func navigateToTheme() {
		split.show(.supplementary)
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
