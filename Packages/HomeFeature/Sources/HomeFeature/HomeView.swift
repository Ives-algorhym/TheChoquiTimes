//
//  SwiftUIView.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import SwiftUI

public struct HomeView: View {

    @State private var selectedSection: HomeSection = .today
    @StateObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel){
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            SectionTabsView(selected: $selectedSection)
            OfflineBannerView(state: viewModel.bannerState)
            content
        }
        .task(id: selectedSection ) {
            await viewModel.load(section: selectedSection)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
            Spacer()
        case .content(let homeFeed):
            VStack(spacing: 0) {
                ScrollView {

                    HomeFeedView(
                        items: homeFeed.items
                    )
                }

            }
        case .offlineEmpty:
            VStack {
                Text("Empty state")
                Spacer()
            }
            .padding()

        case .error(let string):
            Text("Error")
        }
    }
}

#Preview {
    HomeView(
        viewModel: .init(
            useCase: LoadHomeFeedUseCase(
                fetcher: FakeHomeFeedFetcher(),
                cache: FakeHomeCatch()
            ),
            network: NetworkStatusProvider()
        )
    )
}


private struct OfflineBannerView: View {
    let state: HomeViewModel.BannerState

    var body: some View {
        Group {
            if state.isVisible {
                VStack(spacing: 4) {
                    Text("Your device is offline.")
                        .font(.system(size: 15, weight: .semibold))

                    if let lastUpdateText = state.lastUpdateText {
                        Text(lastUpdateText)
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.85))
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.9))
                        .frame(height: 1),
                    alignment: .bottom
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.isVisible)
    }
}
