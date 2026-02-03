//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/1/26.
//

import Foundation

// MARK: - HomeFeedItemKind

/// The visual/content kind of a feed item.
///
/// NOTE: Because this enum has associated values, Swift cannot synthesize `Codable`.
/// We encode/decode using a small type discriminator.
public enum HomeFeedItemKind: Equatable, Codable, Sendable {
    case text
    case image(imageName: String)
    case video(thumbnailName: String, durationText: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case imageName
        case thumbnailName
        case durationText
    }

    private enum KindType: String, Codable {
        case text
        case image
        case video
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(KindType.self, forKey: .type)

        switch type {
        case .text:
            self = .text

        case .image:
            let imageName = try container.decode(String.self, forKey: .imageName)
            self = .image(imageName: imageName)

        case .video:
            let thumbnailName = try container.decode(String.self, forKey: .thumbnailName)
            let durationText = try container.decode(String.self, forKey: .durationText)
            self = .video(thumbnailName: thumbnailName, durationText: durationText)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text:
            try container.encode(KindType.text, forKey: .type)

        case .image(let imageName):
            try container.encode(KindType.image, forKey: .type)
            try container.encode(imageName, forKey: .imageName)

        case .video(let thumbnailName, let durationText):
            try container.encode(KindType.video, forKey: .type)
            try container.encode(thumbnailName, forKey: .thumbnailName)
            try container.encode(durationText, forKey: .durationText)
        }
    }
}

// MARK: - HomeFeedItem

public struct HomeFeedItem: Identifiable, Equatable, Codable {
    public let id: String
    public let section: HomeSection
    public let kind: HomeFeedItemKind

    public let title: String
    public let subtitle: String?
    public let byline: String?
    public let timestampText: String?

    public init(
        id: String,
        section: HomeSection,
        kind: HomeFeedItemKind,
        title: String,
        subtitle: String? = nil,
        byline: String? = nil,
        timestampText: String? = nil
    ) {
        self.id = id
        self.section = section
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.byline = byline
        self.timestampText = timestampText
    }
}

// MARK: - HomeFeed

public struct HomeFeed: Codable, Equatable {
    public let items: [HomeFeedItem]
    public let lastUpdated: Date

    public init(items: [HomeFeedItem], lastUpdated: Date) {
        self.items = items
        self.lastUpdated = lastUpdated
    }
}

extension HomeFeed: Sendable {}
extension HomeFeedItem: Sendable {}
