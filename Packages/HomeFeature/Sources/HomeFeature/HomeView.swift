//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

public struct HomeView: View {

    @State private var selectedSection: HomeSection = .today

    public init(){

    }
    public var body: some View {
        VStack(spacing: 0) {
            SectionTabsView(selected: $selectedSection)
            ScrollView {

                HomeFeedView(
                    items: MockHomeFeed.allItems(for: selectedSection)
                )
            }

        }
    }
}

#Preview {
    HomeView()
}
