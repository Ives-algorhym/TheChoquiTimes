//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import Foundation

struct HomeFeedItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String?
}

enum MockHomeFeed {
    static let items: [HomeFeedItem] = [
        HomeFeedItem(
            id: UUID(),
            title: "Breaking: Major Story of the Day",
            subtitle: "Here is a short summary of the top story."
        ),
        HomeFeedItem(
            id: UUID(),
            title: "Opinion: Why Architecture Matters",
            subtitle: "A deep dive into modular app design."
        ),
        HomeFeedItem(
            id: UUID(),
            title: "Lifestyle: Design Your Morning Routine",
            subtitle: nil
        )
    ]
}
