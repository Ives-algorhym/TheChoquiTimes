//
//  AppContainer.swift
//  TheChoquiTimes
//
//  Created by Ives Murillo on 2/1/26.
//

import Foundation
import HomeFeature
import SwiftUI

struct AppContainer {
    let enviroment: AppEnviroment

    init(enviroment: AppEnviroment) {
        self.enviroment = enviroment
    }

    @MainActor func makeHomeRoot() -> AnyView {
        let homeDependencies = HomeDependencies(
            fetcher: FakeHomeFeedFetcher(),
            cache: FakeHomeCatch()
        )

        return AnyView(makeHomeView(dependencies: homeDependencies) )
    }
}
