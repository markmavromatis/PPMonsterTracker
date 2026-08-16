//
//  LogEventSheet.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import SwiftUI

/// The detail sheet shown after tapping a quick-log button.
/// Lets the user fill in pee amount or poop consistency before saving.
struct LogEventSheet: View {
    let kind: EventKind
    /// Called when the user taps Save. Receives the chosen pee amount (pee events)
    /// and poop details (poop events). Caller is responsible for inserting the event.
    let onSave: (PeeAmount?, PoopConsistency?, Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var peeAmount: PeeAmount = .medium
    @State private var poopConsistency: PoopConsistency = .soft
    @State private var isDiarrhea: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                switch kind {
                case .pee:
                    Section("How much?") {
                        Picker("Amount", selection: $peeAmount) {
                            ForEach(PeeAmount.allCases) { amount in
                                Text(amount.label).tag(amount)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                case .poop:
                    Section("Consistency") {
                        Picker("Consistency", selection: $poopConsistency) {
                            ForEach(PoopConsistency.allCases) { consistency in
                                Text(consistency.label).tag(consistency)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Toggle("Diarrhea", isOn: $isDiarrhea)
                    }
                }
            }
            .navigationTitle("Log \(kind.label)")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch kind {
                        case .pee:
                            onSave(peeAmount, nil, false)
                        case .poop:
                            onSave(nil, poopConsistency, isDiarrhea)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
