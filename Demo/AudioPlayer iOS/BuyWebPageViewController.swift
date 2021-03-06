//
//  WebPageViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/27.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import WebKit
import StoreKit
import QorumLogs
import Alamofire
//mport Kanna

class WebPageViewController: IapSupportWebPageViewController, WKNavigationDelegate {
    
    var url : NSURL!
    var isBackToMainController = false
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var canShowCloseButton = true
    //var backButton: UIBarButtonItem!
    
    var loginUserStore = LoginUserStore()
    
    var leftBarButtonItems: [UIBarButtonItem]?
    
    @IBOutlet weak var webContainer: UIView!
    var loading = LoadingCircle()
    
    var navigationManager : NavigationBarManager!
    var shareView: ShareView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationManager = NavigationBarManager(self)
        shareView = ShareView(frame: CGRect(x : 0, y: UIScreen.main.bounds.height - 233, width: UIScreen.main.bounds.width, height: 233), controller: self)
        navigationManager.shareView = shareView
        
        initIAP()
        initWebView()
        
        closeButton.target = self
        closeButton.action = #selector(returnLastController)
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        leftBarButtonItems = navigationItem.leftBarButtonItems
        
        
        navigationItem.leftBarButtonItems = [backButton]
        navigationItem.rightBarButtonItems = []
        
        navigationManager.setMusicButton()
        navigationManager.setShareButton()
    
        
       // self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func initWebView() {
        super.initWebView()
        var url1 = url.absoluteString
        url1 = Utils.addUserParams(url: url1!)
        url1 = Utils.addDevcieParam(url: url1!)
        url1 = Utils.addBuyInfo(url: url1!)
        QL1(url1)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let frame = self.view.bounds
        var H : CGFloat = 64
        if UIDevice().isX() {
            H -= 24
        }
        
        QL1("minY = \(frame.minY)")
        let newFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - H)
        self.webView = WKWebView(frame: newFrame, configuration: config)
        
   
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1!)
        QL1("NSUrl = \(String(describing: nsurl))")
        let myRequest = NSURLRequest(url: nsurl! as URL);
        //webView.delegate = self
        webView!.load(myRequest as URLRequest);
        
       
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if navigationAction.request.url?.scheme == "tel" {
            
            UIApplication.shared.openURL(navigationAction.request.url!)
            //UIApplication.shared.openURL(URL(string: "tel://13706794299")!)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    /****  webView相关的函数  ***/
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loading.show(view: view)
        QL1("didCommitNavigation called")
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if webView.url != nil {
            QL1("url = \(webView.url!)")
           shareView.setShareUrl((webView.url?.absoluteString)!)
        }
        
        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton, closeButton]
            backButton.action = #selector(webViewBack)

           // self.navigationController?.interactivePopGestureRecognizer?.delegate = self
           // self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        
        QL1("didFinishNavigation called")
        
        
        if webView.url != nil {
            QL1("url = \(webView.url!)")
            shareView.setShareUrl((webView.url?.absoluteString)!)
            shareView.shareManager.loadShareInfo(url: webView.url!)
        }
        
        
        if !webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
            backButton.action = #selector(returnLastController)

           // self.navigationController?.interactivePopGestureRecognizer?.delegate = self
           // self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading.hide()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loading.hide()
    }
    

    @objc func webViewBack() {
        if webView!.canGoBack {
            webView!.goBack()
            if webView?.url != nil {
                //QL1("url = \(webView?.url!)")
                shareView.setShareUrl((webView?.url?.absoluteString)!)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func checkLoginUser() {
        
        //检查一下是否已经登录，如果登录，则直接进入后面的页面
        let loginUser = loginUserStore.getLoginUser()
        if  loginUser != nil {
            QL1("found login user")
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "hasLoginSegue", sender: self)
            }
        } else {
            QL1("no login user")
            DispatchQueue.main.async { () -> Void in
                self.performSegue(withIdentifier: "notLoginSegue", sender: self)
            }
        }
        
    }
    
    
    @objc func returnLastController() {

        if isBackToMainController {
            checkLoginUser()
        } else {
            DispatchQueue.main.async { () -> Void in
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }


    
    
    
}
