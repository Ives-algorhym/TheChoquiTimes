//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation

enum HomeSection: String, CaseIterable, Identifiable {
    case forYou = "For you"
    case today = "Today"
    case opinion = "Opinion"
    case lifeStyle = "Lifestyle"
    case cooking = "Cooking"
    case sports = "Sports"
    case tech = "Technology"

    var id: String { rawValue }
    var title: String { rawValue }
}
