//
//  ContentView.swift
//  Shared
//
//  Created by Damiaan on 09/03/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//		NavigationView {
//			themes
//		}
		
		ThreeColumnView(secondaryContent: Text("This is me")).ignoresSafeArea()
    }
	
	var themes: some View {
		List {
			Button("Go hello") {}
			Text("Something else")
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
