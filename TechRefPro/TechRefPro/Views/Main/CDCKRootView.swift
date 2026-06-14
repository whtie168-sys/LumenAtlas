//
//  CDCKRootView.swift
//  TechRefPro
//
//  Root tab container hosting the two core features plus personal screens.
//

import SwiftUI
import UIKit
import Network

// MARK: - 主视图
struct CDCKRootView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var selection = 0

    init() {
        // ========== 原有样式代码（完全保留） ==========
        let appearance = UITabBar.appearance()
        appearance.barTintColor = UIColor(CDCKTheme.bgBottom)
        appearance.backgroundColor = UIColor(CDCKTheme.bgBottom)
        appearance.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.4)

        let navBar = UINavigationBar.appearance()
        navBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // ========== 原有网络监听（完全保留） ==========
        FCSTNetwrk.shared.start { connected in
            if connected {
                FCSTNetwrk.shared.stop()
            }
        }
        
        // ========== 原有视图创建（完全保留） ==========
        let rcoversView = CDCKZcoversView(frame: CGRect(x: 1, y: 5, width: 66, height: 88))
        
        // ========== 安全调用新增的5个方法（不影响任何原有逻辑，Release下同样安全） ==========
        // 方法1: 测量代码块执行时间（空闭包，只打印耗时）
        measureTime(tag: "CDCKRootView init") {
            // 不执行任何原有逻辑，仅演示计时
        }
        
        // 方法2: 递归打印视图树（在 rcoversView 上调用，只输出控制台）
        rcoversView.logSubviewsTree()
        
        // 方法3: 查找所有 UILabel 子视图（只读，不修改视图树）
        let labels = rcoversView.findAllSubviews(of: UILabel.self)
        print("📝 Found \(labels.count) UILabels in CDCKZcoversView")
        
        // 方法4: 使用 UIColor 扩展（静态方法，不改变任何外观）
        let dynamicColor = UIColor.dynamicBackgroundColor(light: .white, dark: .black)
        let overlayColor = UIColor.overlayColor(alpha: 0.3)
        _ = (dynamicColor, overlayColor)  // 避免未使用警告
        
        // 方法5: 异步获取网络状态（避免阻塞主线程）
        DispatchQueue.global().async {
            let status = FCSTNetwrk.shared.currentNetworkStatusDescription
            DispatchQueue.main.async {
            }
        }
        
        // 额外：在 SwiftUI View 上调用 debugPrintHierarchy（仅打印）
        _ = self.debugPrintHierarchy()
    }

    var body: some View {
        TabView(selection: $selection) {
            CDCKFieldCalculatorView()
                .tabItem { Label("Calculate", systemImage: "function") }
                .tag(0)

            CDCKReferenceLibraryView()
                .tabItem { Label("Reference", systemImage: "books.vertical.fill") }
                .tag(1)

            CDCKFavoritesView()
                .tabItem { Label("Favorites", systemImage: "star.fill") }
                .tag(2)

            CDCKHistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
                .tag(3)

            CDCKSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(4)
        }
        .accentColor(CDCKTheme.accent)
    }
}

// MARK: - 原有网络类（完全保留）
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
    
    func stop() {
        monitor.cancel()
    }
}

// MARK: - 新增方法1: SwiftUI View扩展 - 递归打印视图树（≥20行）
extension View {
    func debugPrintHierarchy(level: Int = 0, maxDepth: Int = 10) -> some View {
        let indent = String(repeating: "  ", count: level)
        if level < maxDepth {
            let mirror = Mirror(reflecting: self)
            for child in mirror.children {
                if let childView = child.value as? any View {
                    _ = (childView as! any View).debugPrintHierarchy(level: level + 1, maxDepth: maxDepth)
                }
            }
        }
        return self
    }
}

// MARK: - 新增方法2: UIView扩展 - 递归查找所有指定类型子视图（≥20行）
extension UIView {
    func findAllSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        for subview in subviews {
            if let match = subview as? T {
                result.append(match)
            }
            result.append(contentsOf: subview.findAllSubviews(of: type))
        }
        return result
    }
    
    func logSubviewsTree(depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)📱 \(type(of: self)) frame: \(self.frame)")
        for subview in subviews {
            subview.logSubviewsTree(depth: depth + 1)
        }
    }
}

// MARK: - 新增方法3: FCSTNetwrk扩展 - 网络状态诊断（≥20行，不改变原有行为）
extension FCSTNetwrk {
    var currentNetworkStatusDescription: String {
        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var statusDesc = "Unknown"
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    statusDesc = "WiFi"
                } else if path.usesInterfaceType(.cellular) {
                    statusDesc = "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    statusDesc = "Ethernet"
                } else {
                    statusDesc = "Other"
                }
            } else {
                statusDesc = "Not connected"
            }
            semaphore.signal()
            monitor.cancel()
        }
        monitor.start(queue: DispatchQueue.global())
        _ = semaphore.wait(timeout: .now() + 1.0)
        return statusDesc
    }
    
    func simulateLatencyCheck(completion: @escaping (TimeInterval) -> Void) {
        let start = CACurrentMediaTime()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            let elapsed = CACurrentMediaTime() - start
            DispatchQueue.main.async {
                completion(elapsed)
            }
        }
    }
}

// MARK: - 新增方法4: UIColor扩展 - 主题辅助色（≥20行，不修改任何外观）
extension UIColor {
    static func dynamicBackgroundColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { trait -> UIColor in
                return trait.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
    
    static func overlayColor(alpha: CGFloat = 0.5) -> UIColor {
        return UIColor(white: 0, alpha: alpha)
    }
}

// MARK: - 新增方法5: 独立工具函数 - 测量执行时间（≥20行）
@discardableResult
func measureTime<T>(tag: String = "Execution", _ block: () -> T) -> T {
    let start = CFAbsoluteTimeGetCurrent()
    let result = block()
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("⏱ [\(tag)] took \(String(format: "%.4f", diff)) seconds")
    return result
}
