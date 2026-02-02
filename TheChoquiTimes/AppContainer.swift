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

    func makeHomeRoot() -> AnyView {
        AnyView(HomeView())
    }
}
