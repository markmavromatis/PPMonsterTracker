//
//  BathroomEvent.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import Foundation
import SwiftUI
import SwiftData

enum EventKind: String, Codable, CaseIterable, Identifiable {
    case pee
    case poop

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pee: return "Pee"
        case .poop: return "Poop"
        }
    }

    var systemImage: String {
        switch self {
        case .pee: return "drop.fill"
        case .poop: return "toilet.fill"
        }
    }

    var tint: Color {
        switch self {
        case .pee: return .yellow
        case .poop: return .brown
        }
    }
}

/// How much the puppy peed. Only meaningful for `pee` events.
enum PeeAmount: String, Codable, CaseIterable, Identifiable {
    case short
    case medium
    case long

    var id: String { rawValue }

    var label: String {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .long: return "Long"
        }
    }
}

/// Stool consistency. Only meaningful for `poop` events.
enum PoopConsistency: String, Codable, CaseIterable, Identifiable {
    case soft
    case hard

    var id: String { rawValue }

    var label: String {
        switch self {
        case .soft: return "Soft"
        case .hard: return "Hard"
        }
    }
}

@Model
final class BathroomEvent {
    var timestamp: Date
    var kindRaw: String
    /// Pee amount — only set for pee events.
    var peeAmountRaw: String?
    /// Poop consistency — only set for poop events.
    var poopConsistencyRaw: String?
    /// Whether the stool was diarrhea — only meaningful for poop events.
    var isDiarrhea: Bool
    var notes: String

    init(
        timestamp: Date = Date(),
        kind: EventKind,
        peeAmount: PeeAmount? = nil,
        poopConsistency: PoopConsistency? = nil,
        isDiarrhea: Bool = false,
        notes: String = ""
    ) {
        self.timestamp = timestamp
        self.kindRaw = kind.rawValue
        self.peeAmountRaw = peeAmount?.rawValue
        self.poopConsistencyRaw = poopConsistency?.rawValue
        self.isDiarrhea = isDiarrhea
        self.notes = notes
    }

    var kind: EventKind {
        get { EventKind(rawValue: kindRaw) ?? .pee }
        set { kindRaw = newValue.rawValue }
    }

    var peeAmount: PeeAmount? {
        get { peeAmountRaw.flatMap(PeeAmount.init(rawValue:)) }
        set { peeAmountRaw = newValue?.rawValue }
    }

    var poopConsistency: PoopConsistency? {
        get { poopConsistencyRaw.flatMap(PoopConsistency.init(rawValue:)) }
        set { poopConsistencyRaw = newValue?.rawValue }
    }
}
