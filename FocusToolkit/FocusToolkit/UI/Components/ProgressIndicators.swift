//
//  ProgressIndicators.swift
//  FocusToolkit
//
//  Reusable circular ring + linear bar used across the dashboard.
//

import SwiftUI

/// Compact circular progress ring with a centered label.
struct CircularProgress<Label: View>: View {
    var progress: Double          // 0...1
    var lineWidth: CGFloat = 8
    var tint: Color = Theme.accent
    var trackColor: Color = Color.white.opacity(0.18)
    @ViewBuilder var label: Label

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.0001, min(1, progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
            label
        }
    }
}

/// Thin rounded progress bar.
struct ProgressBar: View {
    var progress: Double          // 0...1
    var height: CGFloat = 8
    var tint: AnyShapeStyle = AnyShapeStyle(Theme.accentGradient)
    var trackColor: Color = Color.white.opacity(0.12)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                Capsule()
                    .fill(tint)
                    .frame(width: max(0, min(1, progress)) * geo.size.width)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}
