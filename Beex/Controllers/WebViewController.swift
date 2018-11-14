//
//  WebViewController.swift
//  Teco M.E.
//
//  Created by Nour  on 9/30/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: AbstractController,WKNavigationDelegate {
    
   // @IBOutlet weak var webView: CustomWebView!
    var webView: CustomWebView?
    var url:String?
    var userName:String?
    var password:String?
    var nsUrl:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showNavBackButton = true
    
    }
    
    override func customizeView() {
        super.customizeView()
     //   webView = CustomWebView()//(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let webConfiguration = WKWebViewConfiguration()
        webView = CustomWebView(frame: .zero, configuration: webConfiguration)
        webView?.backgroundColor = .white
        webView?.password = self.password
        webView?.username = self.userName
        webView?.navigationDelegate = self
        self.view.addSubview(webView!)
        webView?.anchorToTop(view.topAnchor, left: view.leadingAnchor, bottom: view.bottomAnchor, right: view.trailingAnchor)
      //  webView?.frame = view.frame
//        self.view = webView
        nsUrl = URL(string: self.url ?? "")
        loadWebPage(url: nsUrl!)
    
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
    }
    
    func loadWebPage(url: URL)  {
        var customRequest = URLRequest(url: url)
        customRequest.setValue(userName ?? "", forHTTPHeaderField: "user")
        customRequest.setValue(password ?? "", forHTTPHeaderField: "pass")
        _ = webView!.load(customRequest)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = (navigationResponse.response as! HTTPURLResponse).url else {
            decisionHandler(.cancel)
            return
        }
        
        // If url changes, cancel current request which has no custom headers appended and load a new request with that url with custom headers
        if url != nsUrl {
            nsUrl = url
            decisionHandler(.cancel)
            loadWebPage(url: url)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
        print(webView.url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView?.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.webView?.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    self.webView?.contentMode = .scaleAspectFill
                })
            }
            
        })
    }
}



class CustomWebView: WKWebView {
    var username:String?
    var password:String?
    
    override func load(_ request: URLRequest) -> WKNavigation? {
        do{
            var copy = try request.asURLRequest()
            let head = "USER=\(username ?? "")&PASS=\(password ?? "")"
            copy.httpMethod = "POST"
            let postString = head
            copy.httpBody = postString.data(using: .utf8)
            return super.load(copy)
        }catch{
        return super.load(request)
        }
    }
}
