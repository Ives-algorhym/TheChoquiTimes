//
//  File.swift
//  HomeFeature
//
//  Created by Ives Murillo on 2/2/26.
//

import Foundation

enum MockHomeFeed {

    // Customize how many items per section you want
    static let defaultTotalPerSection = 60

    // Headlines + subtitles per section (reused with rotation)
    @MainActor private static let templates: [HomeSection: [(title: String, subtitle: String?)]] = [
        .today: [
            ("Markets Open Higher After Fresh Data", "Investors weigh rates and earnings."),
            ("Storm System Brings Heavy Rain to the Coast", "Flooding possible in low-lying areas."),
            ("City Council Advances New Housing Proposal", "Supporters call it overdue; critics disagree.")
        ],
        .opinion: [
            ("We Keep Treating Symptoms Instead of Causes", "A case for focusing on root problems."),
            ("The Hidden Cost of Convenience", "Fast delivery has a price we don’t see."),
            ("What ‘Merit’ Really Means in Hiring", "The word sounds neutral. In practice, it isn’t.")
        ],
        .lifeStyle: [
            ("Your Morning Routine Might Be Too Complicated", "Simplify to stick with habits."),
            ("How to Make Small Talk Less Painful", "Questions that lead to real conversation."),
            ("The Case for a ‘Slow Weekend’", "Rest isn’t laziness — it’s maintenance.")
        ],
        .cooking: [
            ("One-Pan Chicken With Lemon and Herbs", "Bright, simple, ready in under 40 minutes."),
            ("Three Weeknight Pastas You’ll Repeat", "Fast sauces, pantry staples."),
            ("A Better Way to Roast Vegetables", "Heat, space, and patience.")
        ],
        .sports: [
            ("Late Goal Seals a Comeback Win", "A dramatic finish after a shaky first half."),
            ("The Rookie Who Changed the Season", "One player unlocked the offense."),
            ("Inside the Training of Elite Fighters", "Recovery, strength, and discipline.")
        ]
    ]

    private static let bylines = [
        "By Staff Report", "By Metro Desk", "By The Choqui Times", "By Sports Desk", "By Opinion"
    ]

    private static let timeLabels = [
        "5m ago", "20m ago", "1h ago", "3h ago", "Yesterday", "2d ago"
    ]

    /// Full set for a section (good for “infinite scroll” simulation)
    @MainActor static func allItems(for section: HomeSection,
                         total: Int = defaultTotalPerSection) -> [HomeFeedItem] {
        let base = templates[section] ?? [("Story", nil)]

        return (0..<total).map { index in
            let t = base[index % base.count]
            return HomeFeedItem(
                id: "\(section.id)-\(index)",                 // ✅ stable
                section: section,
                kind: .text,
                title: "\(t.title) #\(index + 1)",            // number to make scroll feel real
                subtitle: t.subtitle,
                byline: bylines[index % bylines.count],
                timestampText: timeLabels[index % timeLabels.count]
            )
        }
    }
}
