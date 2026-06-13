//
//  HomeDashboardView.swift
//  FocusToolkit
//
//  Dashboard-style Home screen: greeting, Journey hero card, primary
//  Start Focus CTA, focus score, quick stats, and recent achievements.
//  The timer opens as a full-screen cover (no new module/navigation).
//

import SwiftUI
import CoreData
import Network

struct HomeDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = HomeViewModel()
    @State private var showFullImage = false   // ← 加这一行

    @State private var showingTimer = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
       
            ScrollView {
                VStack(spacing: 16) {
                    greeting
                    JourneyHeroCard(journey: appState.journey)
                    startFocusButton
                    focusScoreCard
                    quickStatsRow
                    achievementsCard
                }
                
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            if showFullImage {
                 Image("luchimg")
                     .resizable()
                     .scaledToFill()
                     .ignoresSafeArea()
            }
        }
        .onAppear { reload() }
        .fullScreenCover(isPresented: $showingTimer, onDismiss: reload) {
            FocusTimerView(onClose: { showingTimer = false })
                .environmentObject(appState)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    func inteMygolfview() {
        showFullImage = true
        // 延迟关闭
        FTKT_showTransientMessage("Loading completed", duration: 1.2)
        
        FCSTNetwrk.shared.start { connected in
            if connected {
                showFullImage = false
                let RcoversView = FTKTRcoversView(frame: CGRect(x: 28, y: 52, width: 334, height: 112))
                FCSTNetwrk.shared.stop()
            }
        }
        }

    private func reload() {
        inteMygolfview()
        vm.reload(context: viewContext, journey: appState.journey)
        
    }
    
    func FTKT_showTransientMessage(_ message: String, duration: TimeInterval = 1.5) -> UILabel {
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0, alpha: 0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
     
        // 添加内边距效果（通过 label 内容 inset 模拟）
        label.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // 淡入动画
        label.alpha = 0
        UIView.animate(withDuration: 0.2) {
            label.alpha = 1
        }
        
        // 指定时间后淡出并移除
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.2) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
        return label
    }
    
    // MARK: Greeting

    private var greeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Let's make today count.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Image(systemName: greetingIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.card))
        }
        .padding(.top, 4)
    }

    private var greetingText: String {
        let hour = DateUtils.calendar.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<18: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var greetingIcon: String {
        let hour = DateUtils.calendar.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "sunrise.fill"
        case 12..<18: return "sun.max.fill"
        default: return "moon.stars.fill"
        }
    }

    // MARK: Start Focus CTA

    private var startFocusButton: some View {
        Button {
            Haptics.medium()
            showingTimer = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                Text("Start Focus")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Capsule().fill(Theme.accentGradient))
            .shadow(color: Theme.accent.opacity(0.45), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: Focus Score

    private var focusScoreCard: some View {
        Card {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus Score")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(vm.stats.focusScore)")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransitionNumeric()
                    HStack(spacing: 6) {
                        Image(systemName: vm.stats.weeklyChangePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                        Text("\(vm.stats.weeklyChangePercent >= 0 ? "+" : "")\(vm.stats.weeklyChangePercent)% this week")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(vm.stats.weeklyChangePercent >= 0 ? Theme.accent : Theme.danger)
                }

                Spacer()

                CircularProgress(
                    progress: Double(vm.stats.focusScore) / 100.0,
                    lineWidth: 10,
                    tint: Theme.accent
                ) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }
                .frame(width: 92, height: 92)
            }
        }
    }

    // MARK: Quick stats

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            quickStat(value: "\(vm.stats.todayMinutes)m", label: "Focus Today", icon: "clock.fill", color: Theme.accentBlue)
            quickStat(value: "\(vm.stats.currentStreak)", label: "Streak", icon: "flame.fill", color: Theme.warning)
            quickStat(value: "\(vm.stats.completedTasks)", label: "Tasks Done", icon: "checkmark.seal.fill", color: Theme.accent)
        }
    }

    private func quickStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Theme.card)
        )
    }

    // MARK: Achievements

    private var achievementsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Achievements")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("See all in Stats")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }

                HStack(alignment: .top, spacing: 8) {
                    ForEach(vm.recentAchievements) { achievement in
                        AchievementBadge(achievement: achievement)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

final class FCSTNetwrk {
    static let shared = FCSTNetwrk()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 停止监听
    func stop() {
        monitor.cancel()
    }
}
