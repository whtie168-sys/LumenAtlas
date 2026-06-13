//
//  TimerRing.swift
//  FocusToolkit
//
//  Animated circular progress ring with a soft glow + gradient stroke.
//

import SwiftUI

struct TimerRing: View {
    var progress: Double          // 0...1
    var lineWidth: CGFloat = 16
    var phaseTitle: String
    var timeString: String
    var isRunning: Bool

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: max(0.0001, progress))
                .stroke(
                    Theme.ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.accent.opacity(0.5), radius: isRunning ? 12 : 4)
                .animation(.linear(duration: 0.25), value: progress)

            // Leading dot at the progress head
            Circle()
                .fill(Theme.accent)
                .frame(width: lineWidth + 2, height: lineWidth + 2)
                .offset(y: -ringRadius)
                .rotationEffect(.degrees(progress * 360 - 90 + 90))
                .opacity(progress > 0.001 && progress < 0.999 ? 1 : 0)
                .shadow(color: Theme.accent.opacity(0.8), radius: 6)
                .animation(.linear(duration: 0.25), value: progress)

            // Center label
            VStack(spacing: 6) {
                Text(phaseTitle.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .compatTracking(2)
                    .foregroundStyle(Theme.accent)
                Text(timeString)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)
                    .modifier(NumericTransition())
            }
        }
        .padding(lineWidth / 2)
    }

    // Approximate ring radius for the head dot; matches default frame use.
    private var ringRadius: CGFloat { 130 }
}

/// Animated digit roll on iOS 16+, no-op on iOS 15.
private struct NumericTransition: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}
