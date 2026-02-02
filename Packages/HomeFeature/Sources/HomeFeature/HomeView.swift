//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

public struct HomeView: View {
    public init(){

    }
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeFeedView(items: MockHomeFeed.items)
            }
        }
    }
}

#Preview {
    HomeView()
}
