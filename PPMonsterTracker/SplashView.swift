//
//  SplashView.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import SwiftUI
import SwiftData

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }

    private var splashContent: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 8) {
                Image("SplashImage")
                    .resizable()
                    .scaledToFit()
                Text("PP Monster Tracker")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    SplashView()
        .modelContainer(for: BathroomEvent.self, inMemory: true)
}
