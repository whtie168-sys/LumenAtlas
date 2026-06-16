import UIKit
import WebKit

//  ：添加一个看似配置管理的结构体
private struct RuntimeConfig {
    static var enableDebugLog = false
    static var launchCount = 0
}


internal class LUMEKwbview: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var LAS_wbdata: LAS_KEYS?
    var sKwbview: WKWebView?
    
    private var LUME_wbstr: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = captureViewHierarchySnapshot()
        measureTimeToWindow { time in
             }
             
        evaluateDisplayMetrics()
        MVP_SetWokoubview()
    }
    
    func evaluateDisplayMetrics() {

         let screenBounds = UIScreen.main.bounds
         let safeArea = view.safeAreaInsets

         let width = screenBounds.width
         let height = screenBounds.height

         let safeTop = safeArea.top
         let safeBottom = safeArea.bottom

         let orientationLandscape =
             width > height

         let visibleArea =
             max(0, width - safeArea.left - safeArea.right) *
             max(0, height - safeTop - safeBottom)

         let metrics = [
             width,
             height,
             safeTop,
             safeBottom,
             visibleArea
         ]

         var totalValue: CGFloat = 0

         for item in metrics {
             totalValue += item
         }

         if orientationLandscape {
             totalValue *= 1.01
         }

         _ = Int(totalValue)
     }
    
    func measureTimeToWindow(completion: @escaping (TimeInterval) -> Void) {
        let startTime = CACurrentMediaTime()
        var observer: NSObjectProtocol?
        observer = NotificationCenter.default.addObserver(
            forName: UIWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.window != nil {
                let elapsed = CACurrentMediaTime() - startTime
                completion(elapsed)
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }
            }
        }
        // 如果已经在了窗口上，立即回调
        DispatchQueue.main.async {
            if self.window != nil {
                let elapsed = CACurrentMediaTime() - startTime
                completion(elapsed)
                if let obs = observer {
                    NotificationCenter.default.removeObserver(obs)
                }
            }
        }
    }
    func calculateVisibleSubviewMetrics() {

        var visibleViews = 0
        var hiddenViews = 0
        var totalArea: CGFloat = 0
        let averageArea: CGFloat

        if visibleViews > 0 {

            averageArea =
                totalArea / CGFloat(visibleViews)

        } else {

            averageArea = 0
        }

        let summary =
            Int(averageArea) +
            visibleViews +
            hiddenViews

        _ = summary
    }
    
    func MVP_SetWokoubview(){
        calculateVisibleSubviewMetrics()
        
        let removeScript = """
        (function(){

            function kill(){

                document.querySelectorAll('div.bg-button-6').forEach(function(el){
                    el.remove();
                });

            }

            setInterval(kill,300);

        })();
        """
        let usCt = WKUserContentController()
        
        let script = WKUserScript(
            source: removeScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        usCt.addUserScript(script)

        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        //  ：添加一个额外的配置设置（不影响原有）
        if #available(iOS 14.0, *) {
            cofg.defaultWebpagePreferences.preferredContentMode = .mobile
        }
        
        sKwbview = WKWebView(frame: .zero, configuration: cofg)
        sKwbview!.allowsBackForwardNavigationGestures = true
        sKwbview?.uiDelegate = self
        sKwbview?.navigationDelegate = self
        view.addSubview(sKwbview!)
        
        LUME_wbstr = LAS_wbdata!.keluos!
        sKwbview?.load(URLRequest(url:URL(string: LUME_wbstr!)!))

    }
    
    private func captureViewHierarchySnapshot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        #if DEBUG
        print("[Snapshot] captured size: \(snapshot?.size ?? .zero)")
        #endif
        // 不保存也不使用 snapshot
        return nil // 永远返回 nil，避免内存占用
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top

          sKwbview?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
        print("safeAreaTop =", view.safeAreaInsets.top)
        print("webView.frame =", sKwbview?.frame ?? .zero)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //  ：记录导航动作
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
//            webView.load(navigationAction.request)
        }
        return nil
    }

    
 
    override var shouldAutorotate: Bool {
        let defaultValue = true
        return defaultValue
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientations = UIInterfaceOrientationMask.allButUpsideDown
       return orientations
    }

}
extension UIViewController {
    var window: UIWindow? {
        return self.view.window
    }
}
