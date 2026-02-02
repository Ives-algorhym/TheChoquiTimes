//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

struct HomeFeedCell: View {

    let item: HomeFeedItem

    init(item: HomeFeedItem) {
        self.item = item
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
                .foregroundStyle(.primary)

            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(
            cornerRadius: 12)
            .fill(.background)
            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
        )
    }
}

#Preview {
    let item = HomeFeedItem(id: UUID(), title: "Mock Title", subtitle: "MockSubtilte")
    HomeFeedCell(item: item)
}
