//
//  JourneyHeroCard.swift
//  FocusToolkit
//
//  The dashboard centerpiece: a premium gradient card showing the current
//  journey, its progress ring, and days completed / remaining.
//

import SwiftUI

struct JourneyHeroCard: View {
    let journey: Journey

    var body: some View {
        ZStack {
            // Gradient backdrop with a soft decorative glow.
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.heroGradient)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 180, height: 180)
                        .blur(radius: 8)
                        .offset(x: 120, y: -70)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Current Journey", systemImage: "map.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.85))

                    Text(journey.name)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)

                    HStack(spacing: 18) {
                        statColumn(value: "\(journey.daysCompleted)", label: "Days done")
                        statColumn(value: "\(journey.daysRemaining)", label: "Remaining")
                    }
                }

                Spacer(minLength: 0)

                CircularProgress(
                    progress: journey.progress,
                    lineWidth: 9,
                    tint: .white,
                    trackColor: .white.opacity(0.25)
                ) {
                    VStack(spacing: 0) {
                        Text("\(journey.progressPercent)")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .frame(width: 96, height: 96)
            }
            .padding(20)
        }
        .frame(height: 200)
        .shadow(color: Color(hex: "#7C3AED").opacity(0.35), radius: 18, y: 10)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
