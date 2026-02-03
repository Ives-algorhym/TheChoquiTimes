//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation
import SwiftUI

public protocol HomeFeedFetching: Sendable {
    func fetch(section: HomeSection) async throws -> HomeFeed
}

public protocol HomeFeedCaching: Sendable {
    func load(section: HomeSection) async throws -> HomeFeed?
    func save(_ feed: HomeFeed, section: HomeSection) async throws
}

public struct HomeDependencies {
    public let fetcher: HomeFeedFetching
    public let cache: HomeFeedCaching

    public init(fetcher: HomeFeedFetching, cache: HomeFeedCaching) {
        self.fetcher = fetcher
        self.cache = cache
    }
}

@MainActor public func makeHomeView(dependencies: HomeDependencies) -> some View {
    let useCase = LoadHomeFeedUseCase(
        fetcher: dependencies.fetcher,
        cache: dependencies.cache
    )

    let viewModel = HomeViewModel(
        useCase: useCase,
        network: NetworkStatusProvider()
    )

    return HomeView(viewModel: viewModel)
}

final class LoadHomeFeedUseCase: @preconcurrency HomeFeedingUseCase {

    private let fetcher: HomeFeedFetching
    private let cache: HomeFeedCaching

    init(fetcher: HomeFeedFetching, cache: HomeFeedCaching) {
        self.fetcher = fetcher
        self.cache = cache
    }

    func load(section: HomeSection) async -> HomeFeedLoadOutcome {
        // 1) Cache-first: best-effort read so we can fall back on failures.
        let cached: HomeFeed?
        do {
            cached = try await cache.load(section: section)
        } catch {
            cached = nil
        }

        // 2) Network fetch.
        do {
            let fresh = try await fetcher.fetch(section: section)

            // 3) Persist fresh data (best effort).
            do {
                try await cache.save(fresh, section: section)
            } catch {
                // If saving fails, still show fresh content.
            }

            return .showing(homefeed: fresh, isOffline: false)
        } catch {
            // 4) Network failed: fall back to cache.
            if let cached {
                return .showing(homefeed: cached, isOffline: true)
            } else {
                return .offlineNoCatch
            }
        }
    }


    func hasCached(section: HomeSection) async -> Bool {
        do {
            return (try await cache.load(section: section)) != nil
        } catch {
            return false
        }
    }

    func loadStream(section: HomeSection) async -> AsyncStream<HomeFeedLoadOutcome> {
        AsyncStream { continuation in
            Task {
                var cached: HomeFeed?

                do {
                    cached = try await cache.load(section: section)
                } catch {
                    cached = nil
                }

                if let cached {
                    continuation.yield(.showing(homefeed: cached, isOffline: false))
                }

                do {
                    let fresh = try await fetcher.fetch(section: section)
                    try? await cache.save(fresh, section: section)
                    continuation
                        .yield(.showing(homefeed: fresh, isOffline: true))
                } catch {
                    if let cached {
                        continuation
                            .yield(.showing(homefeed: cached, isOffline: true))
                    } else {
                        continuation.yield(.offlineNoCatch)
                    }
                }
                continuation.finish()
            }
        }
    }
}

protocol HomeFeedingUseCase: Sendable {
    func load(section: HomeSection) async -> HomeFeedLoadOutcome
    func loadStream(section: HomeSection) async -> AsyncStream<HomeFeedLoadOutcome>
    func hasCached(section: HomeSection) async -> Bool

}

extension HomeFeedingUseCase {
    func loadStream(section: HomeSection) -> AsyncStream<HomeFeedLoadOutcome> {
        AsyncStream { continuation in
            Task {
                continuation.yield(await load(section: section))
                continuation.finish()
            }
        }
    }

    func hasCached(section: HomeSection) async -> Bool { false }
}

protocol NetworkStatusProviding {

}

enum HomeFeedLoadOutcome {
    case showing(homefeed: HomeFeed, isOffline: Bool)
    case offlineNoCatch
    case failure(message: String)
}

class NetworkStatusProvider: NetworkStatusProviding {

}

public final class FakeHomeFeedFetcher: HomeFeedFetching {
    public init() {

    }

    public func fetch(section: HomeSection) async throws -> HomeFeed {
        try await Task.sleep(nanoseconds: 300_000_000)
        return await .init(
            items: MockHomeFeed.allItems(for: section),
            lastUpdated: .now
        )
    }
}

public actor FakeHomeCatch: HomeFeedCaching {

    private var storage: [String : HomeFeed] = [:]

    public init() {

    }

    public func load(section: HomeSection) async throws -> HomeFeed? {
        storage[section.id]
    }

    public func save(_ feed: HomeFeed, section: HomeSection) async throws {
        storage[section.id] = feed
    }
}



