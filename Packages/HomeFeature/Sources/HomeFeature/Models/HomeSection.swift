//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation

public enum HomeSection: String, CaseIterable, Identifiable, Codable {
    case forYou = "For you"
    case today = "Today"
    case opinion = "Opinion"
    case lifeStyle = "Lifestyle"
    case cooking = "Cooking"
    case sports = "Sports"
    case tech = "Technology"

    public var id: String { rawValue }
    public var title: String { rawValue }
}

extension HomeSection: Sendable {}
