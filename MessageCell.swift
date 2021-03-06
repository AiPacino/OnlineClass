//
//  MessageCell.swift
//  AudioPlayer iOS
//
//  Created by 金军航 on 2018/10/21.
//  Copyright © 2018 tbaranes. All rights reserved.
//

import UIKit
import SnapKit
import QorumLogs

class MessageCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    var titleLabel : UILabel!
    var descLabel : UILabel!
    var timeLabel : UILabel!
    var nouseLabel : UILabel!
    var separateLine : UIView!
    var height: CGFloat! = 0
    
    var message : Message!
    
    override
    func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width =  UIScreen.main.bounds.width
        if titleLabel == nil {
            makeViews()
        }
        
    }
    
    private func makeViews() {
        
        titleLabel = UILabel()
        descLabel = UILabel()
        timeLabel = UILabel()
        nouseLabel = UILabel()
        separateLine = UIView()
        separateLine.backgroundColor = Utils.hexStringToUIColor(hex: "#D3D3D3")
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(timeLabel)
        addSubview(nouseLabel)
        addSubview(separateLine)
        
        titleLabel.textColor = Utils.hexStringToUIColor(hex: "#FC7C19")
        titleLabel.font = titleLabel.font.withSize(17)
        
        descLabel.textColor = UIColor.darkGray //Utils.hexStringToUIColor(hex: "#555753")
        descLabel.font = descLabel.font.withSize(14)
        
        timeLabel.textColor = Utils.hexStringToUIColor(hex: "#9b9b9b")
        timeLabel.font = timeLabel.font.withSize(13)
        
        nouseLabel.textColor = Utils.hexStringToUIColor(hex: "#9b9b9b")
        nouseLabel.font = nouseLabel.font.withSize(13)
        
        titleLabel.text = ""
        descLabel.text =  ""
        timeLabel.text =  ""
        nouseLabel.text = "查看详情"
        
        
        descLabel.frame.size.width = UIScreen.main.bounds.width - 30
    }
    
    func update() {
        titleLabel.text = message.title
        descLabel.text = message.desc
        timeLabel.text = message.time
        nouseLabel.text = "查看详情"
        //updateConstraints()
    }
    
    func getHeight() -> CGFloat {
        return height
    }
    
    override
    func updateConstraints() {
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        descLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            
            
            descLabel.setLineSpacing(lineSpacing: 1, lineHeightMultiple: 1.1)
            descLabel.numberOfLines = 0
            //descLabel.sizeToFit()
            
            
            var frame = CGSize(width: UIScreen.main.bounds.width - 30, height: 10.0)
            QL1(UIScreen.main.scale)
             QL1(Utils.pixelsToPoints(40.0))
            var newFrame = descLabel.sizeThatFits(frame )
            descLabel.frame.size = newFrame
            
            //QL1("here")
        }
        
        timeLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descLabel.snp.bottom).offset(15)
            make.left.equalTo(titleLabel)
        }
        
        nouseLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descLabel.snp.bottom).offset(15)
            make.right.equalTo(titleLabel)
        }
        
        separateLine.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(nouseLabel.snp.bottom).offset(5)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(0.6)
        }
        
        QL1("descLabel.height = \(descLabel.frame.height)")
        height = 77 + descLabel.frame.height
        
        super.updateConstraints()
    }
   
}
