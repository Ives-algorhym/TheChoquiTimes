//
//  HomeViewModel.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/5/26.
//

import SwiftUI

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

    /// MARK: Cancelation state
    /// The current state load owned by the screen/vm.
    ///  Rule: a new intent  (section change/refresh) cancel the previus one.
    private var loadTask: Task<Void, Never>?

    private var currentSection: HomeSection?

    init(useCase: HomeFeedingUseCase, network: NetworkStatusProviding) {
        self.useCase = useCase
        self.network = network
    }

    // MARK: - Public API (preferred enntry point)
    /// Call this from sync context (e.g Button actions) or when you want the vm
    /// to own the cancelation.
    /// - Cancel any in-flight load  and start a new one (latest intent wins)
    func startLoad(section: HomeSection) {
        cancelLoad()

        currentSection = section

        loadTask = Task { [weak self] in
            guard let self else { return }
            await self.load(section: section)
        }
    }

    func  cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
    }

    // MARK: - Async work
    ///  Async entry point in SwiftUI .task  { await vm.load }  owns the task.
    ///  if you use this style, you  typically dont call startLoad , becouse SwiftUI already create the Task.

    func load(section: HomeSection) async {

        currentSection = section

        guard !Task.isCancelled else { return }

        let useCase = self.useCase
        // ✅ Only show loader when there's no cached content.
        let hasCache = await useCase.hasCached(section: section)
        guard !Task.isCancelled else { return }

        if !hasCache {
            viewState = .loading
        }

        // This stream tipically emits
        // 1) cached (offline) conten fast
        // 2) fresh network content later.
        // The loop must be cancellaation aware, other wise a let emission could update UI
        // after user swithces section.
        for await outcome in  useCase.loadStream(section: section) {

            if Task.isCancelled { break }

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

        if currentSection == section {
            loadTask = nil
        }

    }

    private func format(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d 'at' HH:mm"
        return "Last update on\(df.string(from: date))"
    }
}
