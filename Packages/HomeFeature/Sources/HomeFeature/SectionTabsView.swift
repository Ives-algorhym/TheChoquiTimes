//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation
import SwiftUI

struct SectionTabsView: View {

    @Binding var selected: HomeSection

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(HomeSection.allCases) { section in
                    tab(for: section)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(.background)
    }

    private func tab(for section: HomeSection) -> some View {
        VStack(spacing: 6) {
            Text(section.title)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .font(
                    .system(
                        size: 17,
                        weight: selected == section ? .semibold : .regular
                    )
                )
                .foregroundStyle(selected == section ? .primary : .secondary)
            Rectangle()
                .frame(height: 3)
                .opacity(selected == section ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selected = section
        }
    }
}

#Preview {
    SectionTabsView(selected: .constant(.today))
}
