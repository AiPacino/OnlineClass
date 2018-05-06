//
//  FunctionCell.swift
//  OnlineClass
//
//  Created by 刘兆娜 on 16/5/3.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class FunctionCell: UITableViewCell {
 
}

class ExtendFunctionMananger : NSObject {
    
    var controller : BaseUIViewController!
    var showMaxRows : Int
    static var moreFunction : ExtendFunction?
    var isNeedMore = false
    var extendFunctionStore = ExtendFunctionStore.instance
    
    static var allFunctions = ExtendFunctionMananger.getAllFunctions()
    var functions: [ExtendFunction] {
        get {
            return ExtendFunctionMananger.allFunctions.filter({
                (function: ExtendFunction) -> Bool in
                return extendFunctionStore.isShow(code: function.code, defaultValue: false)
            });
        }
    }
    
    static func getAllFunctions() -> [ExtendFunction] {
        
        ExtendFunctionMananger.moreFunction = ExtendFunction(imageName: "moreFunction", name: "更多", code: "f_more", url: "",
                                      selector: #selector(moreHanlder), isShowDefault: true)
        
        return [
            ExtendFunction(imageName: "commonCard", name: "刷卡", code: "f_paybycard", url: "http://www.baidu.com",
                selector:  #selector(openApp), isShowDefault: true),
            ExtendFunction(imageName: "liveclass", name: "直播课堂", code: "f_class", url: ServiceLinkManager.FunctionUpUrl,
                selector:  #selector(liveClassHandler), isShowDefault: true),
            ExtendFunction(imageName: "visa", name: "快速办卡", code: "f_makecard", url: ServiceLinkManager.FunctionFastCardUrl,
                selector:  #selector(imageHandler), isShowDefault: false),
            ExtendFunction(imageName: "dollar", name: "快速贷款", code: "f_loan", url: ServiceLinkManager.FunctionDaiKuangUrl,
                selector:  #selector(imageHandler), isShowDefault: false),
            
            ExtendFunction(imageName: "shopcart", name: "商城", code: "f_market",  url: ServiceLinkManager.FunctionShopUrl,
                selector:  #selector(imageHandler), isShowDefault: false),
            ExtendFunction(imageName: "car", name: "汽车分期", code: "f_car", url: ServiceLinkManager.FunctionCarLoanUrl,
                selector:  #selector(imageHandler), isShowDefault: false),
            ExtendFunction(imageName: "cardManage", name: "卡片管理", code: "f_cardmanager", url: ServiceLinkManager.FunctionCardManagerUrl,
                selector:  #selector(imageHandler), isShowDefault: true),
            ExtendFunction(imageName: "rmb", name: "我要充值", code: "f_chongzhi",  url: ServiceLinkManager.FunctionJiaoFeiUrl,
                selector:  #selector(imageHandler), isShowDefault: false),
            
            ExtendFunction(imageName: "share", name: "分享", code: "f_share",  url: ServiceLinkManager.FunctionMccSearchUrl,
                selector:  #selector(shareHanlder), isShowDefault: true),
            ExtendFunction(imageName: "customerservice", name: "客服", code: "f_user", url: ServiceLinkManager.FunctionCustomerServiceUrl,
                selector:  #selector(imageHandler), isShowDefault: true),
            ExtendFunction(imageName: "moreFunction", name: "更多", code: "f_more", url: "",
                selector: #selector(moreHanlder), isShowDefault: true)
        ]
        
    }
    
    init(controller: BaseUIViewController, isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.controller = controller
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
        
        super.init()
        ExtendFunctionMananger.allFunctions = ExtendFunctionMananger.getAllFunctions()
    }
    
    
    private func getFunction(code: String) -> ExtendFunction? {
        for function in ExtendFunctionMananger.allFunctions {
            if function.code == code {
                return function
            }
        }
        return nil
    }
    
    init(isNeedMore: Bool = true, showMaxRows : Int = 100) {
        self.showMaxRows = showMaxRows
        self.isNeedMore = isNeedMore
        
        super.init()
    }

    
    let buttonCountEachRow = 4
    func getRowCount() -> Int {
        let rows = (functions.count + buttonCountEachRow - 1) / buttonCountEachRow
        let result = rows > showMaxRows ? showMaxRows : rows
        //print("result = \(result)")
        return result
    }
    
    func isNeedMoreButton() -> Bool {
        return isNeedMore
    }
    
    private func getLastIndex() -> Int {
        let buttonCount = showMaxRows * buttonCountEachRow
        return buttonCount < functions.count ? buttonCount - 1 : functions.count - 1
    }
    
    func getFunctionCell(tableView: UITableView, row: Int) -> FunctionCell {
        var index = row * buttonCountEachRow
        let cell = tableView.dequeueReusableCell(withIdentifier: "functionCell") as! FunctionCell
        cell.subviews.forEach() { subView in
            subView.removeFromSuperview()
        }
        for i in 0...(buttonCountEachRow - 1) {
            
            if index >= functions.count {
                break
            }
            
            var function = functions[index]
            if isNeedMoreButton() && index == getLastIndex() {
                function = ExtendFunctionMananger.moreFunction!
            }
            
            if !isNeedMoreButton() && function.name == ExtendFunctionMananger.moreFunction!.name {
                break
            }
            
            addCellView(row: row, column: i, index: index, function: function, cell: cell)
            index = index + 1
        }
        
        cell.separatorInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.width, 0, 0);
        return cell
    }
    
    
    private func addCellView(row : Int, column : Int, index: Int, function: ExtendFunction, cell: UITableViewCell) -> UIView {
        let interval : CGFloat = UIScreen.main.bounds.width / 4
        let x = interval  * CGFloat(column)
        let cellView = UIView(frame: CGRect(x: x, y: 0, width: interval, height: 79))
        
        
        
        cellView.tag = index
        cell.addSubview(cellView)
        
        let imageView = makeImage(index: index, function: function, superView: cellView)
        let label =     makeLabel(index: index, function: function, superView: cellView)
        
        cellView.addSubview(imageView)
        cellView.addSubview(label)
        
        if function.action != nil {
            cellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: function.action ))
            cellView.isUserInteractionEnabled = true
        }
        
        return cellView
    }
    
    private func getImageWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        if isiPhone4Screen {
            return screenWidth / 4 * 0.6
        } else {
            return screenWidth / 4 * 0.7
        }
    }
    
    var cellHeight:CGFloat {
        get {
            let screenWidth = UIScreen.main.bounds.width
            if isiPhone4Screen {
                return screenWidth / 4 * 0.95
            } else {
                return screenWidth / 4
            }
            
        }
    }
    
    var isiPhonePlusScreen: Bool {
        get {
            return abs(UIScreen.main.bounds.width - 414) < 1;
        }
    }
    
    var isiPhone6Screen: Bool {
        get {
            return abs(UIScreen.main.bounds.width - 375) < 1;
        }
    }
    
    var isiPhone4Screen: Bool {
        get {
            return abs(UIScreen.main.bounds.width - 320) < 1;
        }
    }
    
    private func makeImage(index: Int, function: ExtendFunction, superView: UIView) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: getImageWidth(), height: getImageWidth()))
        imageView.center.x = superView.bounds.width / 2
    
        if isiPhonePlusScreen {
           imageView.center.y = cellHeight / 2 - 1
        } else if isiPhone6Screen {
           imageView.center.y = cellHeight / 2 - 2
        } else {
           imageView.center.y = cellHeight / 2 - 5
        }
        //print("superView.center.x = \(superView.center.x), superView.center.y - 10 = \(superView.center.y - 10)")
        imageView.image = overlayImage(function: function) //UIImage(named: function.imageName)
        imageView.tag = index
        
        return imageView
    }
    
    func overlayImage(function: ExtendFunction) -> UIImage {
        var bottomImage = UIImage(named: function.imageName)!
        let extendFunctionImageStore = ExtendFunctionImageStore()
        QL1("\(function.code):  \(function.name), \(function.imageUrl)")
        if function.imageUrl != "" {
            let image = extendFunctionImageStore.getImage(imageUrl: function.imageUrl)
            if image != nil {
                bottomImage = image!
            }
        }

        
        if !ExtendFunctionStore.instance.hasMessage(code: function.code) {
            return bottomImage
        }
        
        
        let topImage = UIImage(named: "message_one")!
        
        let newSize = CGSize(width: getImageWidth(), height: getImageWidth()) // set this to what you need
        let ratio : CGFloat = 0.32
        let messageSize = CGSize(width: getImageWidth() * ratio, height: getImageWidth() * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let x = getImageWidth() - abs(getImageWidth() - getImageWidth() * ratio) * 0.9 / 2
        let y = getImageWidth() * ratio / 5 - 4
        
        bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        topImage.draw(in: CGRect(origin: CGPoint(x: x, y: CGFloat(y)), size: messageSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func makeLabel(index: Int, function: ExtendFunction, superView: UIView) -> UILabel {
        let screenWidth = UIScreen.main.bounds.width
        let labelWidth =  screenWidth / 4
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 21))
        label.tag = index
        
        label.center.x = superView.bounds.width / 2
        if isiPhonePlusScreen {
            label.center.y = cellHeight / 2 + getImageWidth() / 2 + 9
        } else if isiPhone6Screen {
            label.center.y = cellHeight / 2 + getImageWidth() / 2 + 3
        } else {
            label.center.y = cellHeight / 2 + getImageWidth() / 2 + 3
        }

        label.textAlignment = .center
        label.font = label.font.withSize(13)
        label.textColor = UIColor.black
        label.text = function.name
        
        return label
    }
    
    @objc func imageHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)
        let function = functions[index!]
        let params : [String: String] = ["url": function.url, "title": function.name]
        controller.performSegue(withIdentifier: "loadWebPageSegue", sender: params)
    }
    
    func unSupportHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)
        controller.displayMessage(message: "敬请期待")
    }
    
    @objc func moreHanlder(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)
        controller.performSegue(withIdentifier: "moreFunctionSegue", sender: nil)
    }
    
    @objc func openApp(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)

        let jfzfHooks = "com.uen.jfzfxpush://"
        let jfzfUrl = NSURL(string: jfzfHooks)
        if UIApplication.shared.canOpenURL(NSURL(string: jfzfHooks)! as URL)
        {
            UIApplication.shared.openURL(jfzfUrl! as URL)
            
        } else {
            let params : [String: String] = ["url": "http://jf.yhkamani.com/dlios.html", "title": "巨方支付下载"]
            controller.performSegue(withIdentifier: "loadWebPageSegue", sender: params)
        }
    }
    
    @objc func shareHanlder(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)
        
        controller.performSegue(withIdentifier: "codeImageSegue", sender: nil)
    }
    
    @objc func liveClassHandler(sender: UITapGestureRecognizer? = nil) {
        let index = sender?.view?.tag
        clearFunctionMessage(index: index!)
        controller.performSegue(withIdentifier: "beforeCourseSegue", sender: CourseType.LiveCourse)
    }
    
    private func clearFunctionMessage(index: Int) {
        let function = functions[index]
        extendFunctionStore.clearMessage(code: function.code, value: 0)
        let request = ClearFunctionMessageRequest()
        request.code = function.code
        BasicService().sendRequest(url: ServiceConfiguration.CLEAR_FUNCTION_MESSAGE, request: request) {
            (resp: ClearFunctionMessageResponse) -> Void in
            if resp.isFail {
                QL4(resp.errorMessage)
                return
            }
        }
    }
}

class ExtendFunction {
    var imageName = ""
    var _name = ""
    var url = ""
    var code = ""
    var isShowDefault = true
    var isSupport = false
    var messageCount = 0
    var action : Selector
    
    var hasMessage: Bool {
        get {
            return self.messageCount > 0
        }
    }
    
    var name: String {
        get {
            return ExtendFunctionStore.instance.getFunctionName(code: self.code, defaultValue: _name)
        }
    }
    
    var imageUrl: String {
        get {
            return ExtendFunctionStore.instance.getImageUrl(code: self.code)
        }
    }
    
    init(imageName: String, name: String, code: String, url: String, selector: Selector, isShowDefault: Bool) {
        self.imageName = imageName
        self._name = name
        self.url = url
        self.action = selector
        self.code = code
        self.isShowDefault = isShowDefault
    }
    
    func dummy() {
        
    }
    
    init(code: String, isShowDefault: Bool, messageCount: Int) {
        self.code = code
        self.isShowDefault = isShowDefault
        self.messageCount = messageCount
        //TODO:  
        self.action = Selector("")
    }
}
