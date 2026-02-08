//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation
import SwiftUI
import Core

public protocol HomeFeedFetching: Sendable {
    func fetch(section: HomeSection) async throws -> HomeFeed
}

public protocol HomeFeedCaching: Sendable {
    func load(section: HomeSection) async throws -> HomeFeed?
    func save(_ feed: HomeFeed, section: HomeSection) async throws
}

/// Concurrency-safe flag used to deterministically simulate offline/online behavior in dev/previews.
actor OfflineSimulationState {
    private var isOffline: Bool

    init(isOffline: Bool) {
        self.isOffline = isOffline
    }

    func get() -> Bool { isOffline }
    func set(_ value: Bool) { isOffline = value }
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
        useCase: useCase
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

    func loadStream(section: HomeSection)  -> AsyncStream<HomeFeedLoadOutcome> {
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
                        .yield(.showing(homefeed: fresh, isOffline: false))
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
    func loadStream(section: HomeSection) -> AsyncStream<HomeFeedLoadOutcome>
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

/// Deterministic network simulation for dev/previews/tests.
/// remainingSuccesses = 1 => first request succeeds, then all subsequent requests fail.
public actor FakeNetworkScript {
    private var remainingSuccesses: Int

    public init(remainingSuccesses: Int) {
        self.remainingSuccesses = remainingSuccesses
    }

    public func shouldFailNow() -> Bool {
        if remainingSuccesses > 0 {
            remainingSuccesses -= 1
            return false
        }
        return true
    }
}

public final class FakeHomeFeedFetcher: HomeFeedFetching {

    private let script: FakeNetworkScript

    /// Default: succeed once (populate cache), then fail (simulate offline).
    public init(script: FakeNetworkScript = FakeNetworkScript(remainingSuccesses: 1)) {
        self.script = script
    }

    public func fetch(section: HomeSection) async throws -> HomeFeed {
        // Simulate network latency (supports cancellation).
        try await Task.sleep(nanoseconds: 300_000_000)

        // Deterministic offline behavior.
        if await script.shouldFailNow() {
            throw URLError(.notConnectedToInternet)
        }

        return .init(
            items: MockHomeFeed.allItems(for: section),
            lastUpdated: .now
        )
    }
}

public actor FakeHomeCatch: HomeFeedCaching {

    private var storage: [String: HomeFeed] = [:]

    // ✅ Eviction policy (simple + interview-friendly)
    private let maxAge: TimeInterval = 60       // 1 hour
    private let maxEntries: Int = 10                // keep at most 10 sections

    private func pruneExpired(now: Date = .now) {
        storage = storage.filter { (_, feed) in
            now.timeIntervalSince(feed.lastUpdated) <= maxAge
        }
    }

    private func pruneToMaxEntries() {
        guard storage.count > maxEntries else { return }

        // Evict oldest feeds by lastUpdated until within limit.
        let sortedOldestFirst = storage.sorted { $0.value.lastUpdated < $1.value.lastUpdated }
        let overflow = storage.count - maxEntries

        for i in 0..<overflow {
            storage.removeValue(forKey: sortedOldestFirst[i].key)
        }
    }

    public init() {}

    public func load(section: HomeSection) async throws -> HomeFeed? {
        pruneExpired()
        return storage[section.id]
    }

    public func save(_ feed: HomeFeed, section: HomeSection) async throws {
        pruneExpired()
        storage[section.id] = feed
        pruneToMaxEntries()
    }
}



