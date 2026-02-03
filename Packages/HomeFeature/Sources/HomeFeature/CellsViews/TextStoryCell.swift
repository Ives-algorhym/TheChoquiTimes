//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import SwiftUI

struct TextStoryCell: View {
    let title: String
    let subtitle: String?
    let readTimeText: String?
    let showAccessory: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Headline
            Text(title)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .center, spacing: 8) {
                if let readTimeText {
                    Text(readTimeText)
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold,
                                design: .default
                            )
                        )
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                Spacer()

                if showAccessory {
                    Image(systemName: "headphones")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }


        }


        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

#Preview {
    TextStoryCell(
        title: "Man Tricked by Scammers Gets 21 Years to Life for Killing Uber Driver",
        subtitle: "Scammers on the phone had threatened to kill the 83-year-old man if he didn’t hand over $12,000, just as an Uber driver arrived to pick up a package.",
        readTimeText: "3 minut",
        showAccessory: true
    )
}




