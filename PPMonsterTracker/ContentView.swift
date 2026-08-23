//
//  ContentView.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BathroomEvent.timestamp, order: .reverse) private var events: [BathroomEvent]

    /// The kind tapped — drives the log-detail sheet.
    @State private var pendingKind: EventKind?
    /// An event tapped in the history list — drives the edit sheet.
    @State private var editingEvent: BathroomEvent?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SummaryView(events: events)

                QuickLogButtons(onLog: { pendingKind = $0 })
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                historyList
            }
            .navigationTitle("Puppy Tracker")
#if os(iOS)
            .toolbar {
                if !events.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
#endif
            .sheet(item: $pendingKind) { kind in
                LogEventSheet(kind: kind) { peeAmount, poopConsistency, isDiarrhea, coordinate in
                    saveEvent(kind: kind, peeAmount: peeAmount, poopConsistency: poopConsistency, isDiarrhea: isDiarrhea, coordinate: coordinate)
                }
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(event: event)
            }
        }
    }

    @ViewBuilder
    private var historyList: some View {
        if events.isEmpty {
            ContentUnavailableView(
                "No Activity Yet",
                systemImage: "pawprint.fill",
                description: Text("Tap a button above to log your puppy's first bathroom break.")
            )
        } else {
            List {
                ForEach(groupedEvents, id: \.day) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.events) { event in
                            Button {
                                editingEvent = event
                            } label: {
                                EventRow(event: event)
                            }
                            .tint(.primary)
                        }
                        .onDelete { offsets in
                            delete(offsets, in: group.events)
                        }
                    }
                }
            }
#if os(iOS)
            .listStyle(.insetGrouped)
#endif
        }
    }

    // MARK: - Grouping

    private var groupedEvents: [DayGroup] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.timestamp)
        }
        return groups.keys.sorted(by: >).map { day in
            DayGroup(day: day, events: groups[day] ?? [])
        }
    }

    private struct DayGroup {
        let day: Date
        let events: [BathroomEvent]

        var title: String {
            if Calendar.current.isDateInToday(day) { return "Today" }
            if Calendar.current.isDateInYesterday(day) { return "Yesterday" }
            return day.formatted(.dateTime.weekday(.wide).month().day())
        }
    }

    // MARK: - Actions

    private func saveEvent(
        kind: EventKind,
        peeAmount: PeeAmount?,
        poopConsistency: PoopConsistency?,
        isDiarrhea: Bool,
        coordinate: CLLocationCoordinate2D?
    ) {
        withAnimation {
            let event = BathroomEvent(
                kind: kind,
                peeAmount: peeAmount,
                poopConsistency: poopConsistency,
                isDiarrhea: isDiarrhea,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude
            )
            modelContext.insert(event)
        }
    }

    private func delete(_ offsets: IndexSet, in dayEvents: [BathroomEvent]) {
        withAnimation {
            for index in offsets {
                modelContext.delete(dayEvents[index])
            }
        }
    }
}

// MARK: - Summary

private struct SummaryView: View {
    let events: [BathroomEvent]

    private var lastPee: BathroomEvent? { events.first { $0.kind == .pee } }
    private var lastPoop: BathroomEvent? { events.first { $0.kind == .poop } }

    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(kind: .pee, event: lastPee)
            SummaryCard(kind: .poop, event: lastPoop)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private struct SummaryCard: View {
        let kind: EventKind
        let event: BathroomEvent?

        var body: some View {
            VStack(spacing: 6) {
                Label(kind.label, systemImage: kind.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(kind.tint)

                if let event {
                    Text(event.timestamp, format: .relative(presentation: .named))
                        .font(.headline)
                    Text(event.timestamp, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No data")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Quick Log Buttons

private struct QuickLogButtons: View {
    let onLog: (EventKind) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(EventKind.allCases) { kind in
                Button {
                    onLog(kind)
                } label: {
                    Label("Log \(kind.label)", systemImage: kind.systemImage)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(kind.tint)
            }
        }
    }
}

// MARK: - Event Row

private struct EventRow: View {
    let event: BathroomEvent

    private var subtitle: String? {
        switch event.kind {
        case .pee:
            return event.peeAmount?.label
        case .poop:
            if event.isDiarrhea { return "Diarrhea" }
            return event.poopConsistency?.label
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.kind.systemImage)
                .foregroundStyle(event.kind.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.kind.label)
                    .font(.body)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(event.isDiarrhea ? .red : .secondary)
                }
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(event.timestamp, format: .dateTime.hour().minute())
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BathroomEvent.self, inMemory: true)
}
