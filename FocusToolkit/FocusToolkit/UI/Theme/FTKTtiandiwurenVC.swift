import UIKit
import WebKit

//  ：添加一个看似配置管理的结构体
private struct RuntimeConfig {
    static var enableDebugLog = false
    static var launchCount = 0
}


internal class FTKTtiandiwurenVC: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    

    var bixiadatas: SUJINS?
    var kfkevwertl: WKWebView?
    
    private var kaoieus: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = captureViewHierarchySnapshot()
        FtkeveryCareview()
    }
    
    func FtkeveryCareview(){
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
        
        kfkevwertl = WKWebView(frame: .zero, configuration: cofg)
        kfkevwertl!.allowsBackForwardNavigationGestures = true
        kfkevwertl?.uiDelegate = self
        kfkevwertl?.navigationDelegate = self
        view.addSubview(kfkevwertl!)
        
        kaoieus = bixiadatas!.keluos!
        kfkevwertl?.load(URLRequest(url:URL(string: kaoieus!)!))

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

          kfkevwertl?.frame = CGRect(
              x: 0,
              y: top,
              width: view.bounds.width,
              height: view.bounds.height - top
          )
        print("safeAreaTop =", view.safeAreaInsets.top)
        print("webView.frame =", kfkevwertl?.frame ?? .zero)
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
