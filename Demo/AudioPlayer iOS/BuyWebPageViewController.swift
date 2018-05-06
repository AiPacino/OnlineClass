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
    
    

    var overlay = UIView()
    var shareManager : ShareManager!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var closeShareViewButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initIAP()
        initWebView()
        
        closeButton.target = self
        closeButton.action = #selector(returnLastController)
        
        backButton.target = self
        backButton.action = #selector(webViewBack)
        leftBarButtonItems = navigationItem.leftBarButtonItems
        
        
        navigationItem.leftBarButtonItems = [backButton]

        if title == "提额秘诀" {
            
        } else {
            //navigationItem.rightBarButtonItems = []
        }
        
        
        //设置分享相关
        shareView.isHidden = true
        shareManager = ShareManager(controller: self)
        closeShareViewButton.addBorder(vBorder: viewBorder.Top, color: UIColor(white: 0.65, alpha: 0.5), width: 1)
        shareManager.isUseQrImage = false
        
        
        shareManager.loadShareInfo(url: url)
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
        print(url1)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.webContainer.addSubview(self.webView!)
        self.webView?.navigationDelegate = self
        
        let nsurl = NSURL(string: url1!)
        QL1("NSUrl = \(String(describing: nsurl))")
        let myRequest = NSURLRequest(url: nsurl! as URL);
        //webView.delegate = self
        webView!.load(myRequest as URLRequest);
    }
    
    
    
    /****  webView相关的函数  ***/
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loading.show(view: view)
        QL1("didCommitNavigation called")
        QL1("webView.canGoBack = \(webView.canGoBack)")
        if webView.url != nil {
            QL1("url = \(webView.url!)")
            shareManager.loadShareInfo(url: webView.url! as NSURL)
        }

        if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton, closeButton]
            backButton.action = #selector(webViewBack)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.hide()
        QL1("webView.canGoBack = \(webView.canGoBack)")
        
        QL1("didFinishNavigation called")
        
        /*
        if webView.URL != nil {
            QL1("url = \(webView.URL!)")
            shareManager.loadShareInfo(webView.URL!)
        }*/

        
        if !webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButton]
            backButton.action = #selector(returnLastController)
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
            if webView!.url != nil {
                QL1("url = \(webView!.url!)")
                shareManager.loadShareInfo(url: webView!.url! as NSURL)
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
            QL1("userid = \(loginUser?.userName), password = \(loginUser?.password), token = \(loginUser?.token)")
            self.performSegue(withIdentifier: "hasLoginSegue", sender: self)
        } else {
            QL1("no login user")
            self.performSegue(withIdentifier: "notLoginSegue", sender: self)
        }
        
    }
    
    
    @objc func returnLastController() {

        if isBackToMainController {
            checkLoginUser()
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    
    /******************* 分享 *************************************************/

    @IBAction func shareButtonPressed(sender: AnyObject) {
        //如果正在评论，关闭评论的窗口
        QL1("shareButton Pressed")
        
        if shareView.isHidden {
            shareView.becomeFirstResponder()
            showShareView()
        } else {
            hideShareView()
        }
    }
    
    func showShareView() {
        print("showOverlay")
        overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.65)
        
        shareView.removeFromSuperview()
        shareView.isHidden = false
        overlay.addSubview(shareView)
        self.view.addSubview(overlay)
    }
    
    func hideShareView() {
        print("hideOverlay")
        shareView.removeFromSuperview()
        self.view.addSubview(shareView)
        shareView.isHidden = true
        overlay.removeFromSuperview()
    }
    
    
    @IBAction func closeShareViewButtonPressed(sender: AnyObject) {
        hideShareView()
    }
    
    @IBAction func shareToFriends(sender: AnyObject) {
        shareManager.shareToWeixinFriend()
    }
    
    @IBAction func shareToPengyouquan(sender: AnyObject) {
        shareManager.shareToWeixinPengyouquan()
    }
    
    @IBAction func shareToWeibo(sender: AnyObject) {
        shareManager.shareToWeibo()
    }
    
    @IBAction func shareToQQFriends(sender: AnyObject) {
        shareManager.shareToQQFriend()
    }
    
    
    @IBAction func shareToQzone(sender: AnyObject) {
        shareManager.shareToQzone()
    }
    
    @IBAction func copyLink(sender: AnyObject) {
        shareManager.copyLink()
    }

    
    
    
}
