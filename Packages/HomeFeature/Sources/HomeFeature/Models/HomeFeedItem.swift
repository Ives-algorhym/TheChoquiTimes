//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import Foundation

enum HomeFeedItemKind {
    case text
    case image(imageName: String)
    case video(thumbNail: String, durationText: String)
}

struct HomeFeedItem: Identifiable {
    let id: String
    let section: HomeSection
    let itemKind: HomeFeedItemKind
    let title: String
    let subtitle: String?
    let byLine: String?
    let timeStamptText: String?

    init(
        id: String,
        section: HomeSection,
        itemKind: HomeFeedItemKind,
        title: String,
        subtitle: String?,
        byLine: String?,
        timeStamptText: String?
    ) {
        self.id = id
        self.section = section
        self.itemKind = itemKind
        self.title = title
        self.subtitle = subtitle
        self.byLine = byLine
        self.timeStamptText = timeStamptText
    }
}


