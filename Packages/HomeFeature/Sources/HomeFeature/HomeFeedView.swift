//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

struct HomeFeedView: View {
    private let items: [HomeFeedItem]

    init(items: [HomeFeedItem]) {
        self.items = items
    }
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                HomeFeedCell(item: item)
            }
        }
    }
}

#Preview {
    let items = MockHomeFeed.allItems(for: .today)
    HomeFeedView(items: items)
}
