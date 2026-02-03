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

@MainActor
final class HomeViewModel: ObservableObject {

    enum ViewState {
        case loading
        case content(HomeFeed)
        case offlineEmpty
        case error(String)
    }

    struct BannerState: Equatable {
        var isVisible: Bool
        var lastUpdateText: String?
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var bannerState = BannerState(
        isVisible: true,
        lastUpdateText: nil
    )

    private let useCase: any HomeFeedingUseCase & Sendable
    private let network: NetworkStatusProviding

    init(useCase: HomeFeedingUseCase, network: NetworkStatusProviding) {
        self.useCase = useCase
        self.network = network
    }

    func load(section: HomeSection) async {


        let useCase = self.useCase
        // ✅ Only show loader when there's no cached content.
        let hasCache = await useCase.hasCached(section: section)
        if !hasCache {
            viewState = .loading
        }
        for await outcome in  useCase.loadStream(section: section) {
            switch outcome {
            case .showing(let feed, let isOffline):
                viewState = .content(feed)
                bannerState.isVisible = isOffline
                bannerState.lastUpdateText = format(feed.lastUpdated)
            case .offlineNoCatch:
                viewState = .offlineEmpty
                bannerState.isVisible = true
                bannerState.lastUpdateText = nil
            case .failure(let message):
                viewState = .error(message)

            }
        }

    }

    private func format(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d 'at' HH:mm"
        return "Last update on\(df.string(from: date))"
    }
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
