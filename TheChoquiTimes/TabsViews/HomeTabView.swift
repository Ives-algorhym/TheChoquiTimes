//
//  HomeTabView.swift
//  TheChoquiTimes
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

struct HomeTabView: View {

    let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        NavigationStack {
            container.makeHomeRoot()
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        ZStack {
                            Image("mastHeadTitle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 34)
                                .padding(.vertical, 10)

                            HStack(spacing: 10) {
                                Spacer()
                                Button {} label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .foregroundStyle(.primary)
                                        .frame(width: 44, height: 44)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                        Divider()
                    }
                    .background(.background)
                }
        }
    }
}

#Preview {
    HomeTabView(container: AppContainer(enviroment: .prod))
}
