//
//  LogEventSheet.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import SwiftUI
import CoreLocation

/// The detail sheet shown after tapping a quick-log button.
/// Lets the user fill in pee amount or poop consistency before saving.
struct LogEventSheet: View {
    let kind: EventKind
    /// Called when the user taps Save. Caller is responsible for inserting the event.
    let onSave: (PeeAmount?, PoopConsistency?, Bool, CLLocationCoordinate2D?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var peeAmount: PeeAmount = .medium
    @State private var poopConsistency: PoopConsistency = .soft
    @State private var isDiarrhea: Bool = false
    @State private var locationManager = LocationManager()

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

                Section {
                    HStack {
                        Image(systemName: locationStatusImage)
                            .foregroundStyle(locationStatusColor)
                        Text(locationStatusText)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
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
                        let coord = locationManager.coordinate
                        switch kind {
                        case .pee:
                            onSave(peeAmount, nil, false, coord)
                        case .poop:
                            onSave(nil, poopConsistency, isDiarrhea, coord)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }

    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return "Location access denied in Settings"
        case .notDetermined:
            return "Requesting location access…"
        default:
            return locationManager.coordinate != nil ? "Location captured" : "Acquiring location…"
        }
    }

    private var locationStatusImage: String {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return "location.slash.fill"
        default:
            return locationManager.coordinate != nil ? "location.fill" : "location"
        }
    }

    private var locationStatusColor: Color {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            return .red
        default:
            return locationManager.coordinate != nil ? .green : .secondary
        }
    }
}
