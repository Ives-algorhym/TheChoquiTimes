//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import Foundation

struct HomeFeedItem: Identifiable {
    let id: String
    let section: HomeSection
    let title: String
    let subtitle: String?
    let byLine: String?
    let timeStamptText: String?

    init(
        id: String,
        section: HomeSection,
        title: String,
        subtitle: String?,
        byLine: String?,
        timeStamptText: String?
    ) {
        self.id = id
        self.section = section
        self.title = title
        self.subtitle = subtitle
        self.byLine = byLine
        self.timeStamptText = timeStamptText
    }
}


