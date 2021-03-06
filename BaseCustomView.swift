//
//  BaseCustomView.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/5/12.
//  Copyright © 2018年 tbaranes. All rights reserved.
//

import UIKit
import QorumLogs

class BaseCustomView: UIView {

    //初始化默认属性配置
    func initialSetup(){
    }
    
    //布局相关设置
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    

    /*** 下面的几个方法都是为了让这个自定义类能将xib里的view加载进来。这个是通用的，我们不需修改。 ****/
    var contentView:UIView!
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        let v = loadViewFromNib()
    
        let newFrame = CGRect(x: 0, y: 0,  width: frame.width, height: frame.height)
        //QL1("x = \(frame.minX), y = \(frame.minY), width = \(frame.width), height = \(frame.height)")
        //QL1("x = \(newFrame.minX), y = \(newFrame.minY), width = \(newFrame.width), height = \(newFrame.height)")
        v.frame = newFrame
        
        addSubview(v)
        
        //初始化属性配置
        initialSetup()
    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = loadViewFromNib()
        addSubview(contentView)
        //初始化属性配置
        initialSetup()
    }
    //加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

}
