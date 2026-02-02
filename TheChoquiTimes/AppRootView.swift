//
//  AppRootView.swift
//  TheChoquiTimes
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

struct AppRootView: View {

    private let container = AppContainer(enviroment: .live)
    var body: some View {
        TabView {
            HomeTabView(container: container)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Text("Watch")
                .tabItem {
                    Label("Watch", systemImage: "play.rectangle")
                }
            Text("Listen")
                .tabItem {
                    Label("Listen", systemImage: "headphones")
                }
            Text("Play")
                .tabItem {
                    Label("Play", systemImage: "square.grid.2x2")
                }
            Text("You")
                .tabItem {
                    Label("You", systemImage: "person")
                }
        }
    }
}

#Preview {
    AppRootView()
}
