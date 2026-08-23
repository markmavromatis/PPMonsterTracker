//
//  EventEditView.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import SwiftUI
import SwiftData
import MapKit

/// A form for editing an existing bathroom event.
struct EventEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var event: BathroomEvent

    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $event.kind) {
                        ForEach(EventKind.allCases) { kind in
                            Label(kind.label, systemImage: kind.systemImage).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("When") {
                    DatePicker(
                        "Time",
                        selection: $event.timestamp,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                switch event.kind {
                case .pee:
                    Section("How much?") {
                        Picker("Amount", selection: peeAmountBinding) {
                            ForEach(PeeAmount.allCases) { amount in
                                Text(amount.label).tag(PeeAmount?.some(amount))
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                case .poop:
                    Section("Consistency") {
                        Picker("Consistency", selection: poopConsistencyBinding) {
                            ForEach(PoopConsistency.allCases) { consistency in
                                Text(consistency.label).tag(PoopConsistency?.some(consistency))
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Toggle("Diarrhea", isOn: $event.isDiarrhea)
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $event.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let lat = event.latitude, let lon = event.longitude {
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    Section("Location") {
                        Map(position: .constant(.region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        )))) {
                            Marker("", coordinate: coord)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .allowsHitTesting(false)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Event")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: event.kind) { _, newKind in
                // Clear fields that don't apply to the new kind.
                if newKind != .pee { event.peeAmount = nil }
                if newKind != .poop {
                    event.poopConsistency = nil
                    event.isDiarrhea = false
                }
            }
            .confirmationDialog(
                "Delete this event?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(event)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var peeAmountBinding: Binding<PeeAmount?> {
        Binding(
            get: { event.peeAmount },
            set: { event.peeAmount = $0 }
        )
    }

    private var poopConsistencyBinding: Binding<PoopConsistency?> {
        Binding(
            get: { event.poopConsistency },
            set: { event.poopConsistency = $0 }
        )
    }
}
