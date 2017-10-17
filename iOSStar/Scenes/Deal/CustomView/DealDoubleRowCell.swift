//
//  DealDoubleRowCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/23.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class DealDoubleRowCell: UITableViewCell {
    

    var dealType:[Int:String] = [-1:"回收",1:"获取"]
    var dealStatus:[Int32:String] = [-2:"委托失败",-1 : "委托失败", 0:"委托中", 1:"委托中", 2:"委托成功"]
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var underNameLabel: UILabel!
    
    @IBOutlet weak var secondLabel1: UILabel!
    
    @IBOutlet weak var secondLabel2: UILabel!
    
    @IBOutlet weak var thirdLabel1: UILabel!
    
    @IBOutlet weak var thirdLabel2: UILabel!
    
    @IBOutlet weak var lastLabel1: UILabel!
    
    @IBOutlet weak var lastLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setEntruset(model:EntrustListModel) {
        StartModel.getStartName(startCode: model.symbol) { (response) in
            
            if let star = response as? StartModel {
                self.nameLabel.text = star.name
            } else {
                self.nameLabel.text = ""
            }
        }
        underNameLabel.text = model.symbol
        secondLabel1.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(model.positionTime), format: "YYYY-MM-dd")
        secondLabel2.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(model.positionTime), format: "HH:mm:SS")
        thirdLabel1.text = String(format: "%.2f", model.openPrice)
        thirdLabel2.text = "\(model.amount)"
        lastLabel1.text = dealType[model.buySell]
        lastLabel2.text = dealStatus[model.handle]
        
        if model.handle == 0 {
            setColor(color: UIColor(hexString: "666666"))
        } else {
            setColor(color: UIColor(hexString: "cccccc"))

        }
    }
    
    func setOrderModel(model:OrderListModel) {
        StartModel.getStartName(startCode: model.symbol) { (response) in
            
            if let star = response as? StartModel {
                self.nameLabel.text = star.name
            } else {
                self.nameLabel.text = ""
            }
        }
        underNameLabel.text = model.symbol
        secondLabel1.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(model.openTime), format: "YYYY-MM-dd")
        secondLabel2.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(model.openTime), format: "HH:mm:SS")
        thirdLabel1.text = "\(model.openPrice)"
        thirdLabel2.text = "\(model.amount)"
        var type = 1
        if model.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id ?? 0{
           type = -1
        }
        lastLabel1.text = dealType[type]
        lastLabel2.text = "\(Double(model.amount) * model.openPrice)"
    }
    
    func setColor(color:UIColor) {
        nameLabel.textColor = color
        underNameLabel.textColor = color
        secondLabel1.textColor = color
        secondLabel2.textColor = color
        thirdLabel1.textColor = color
        thirdLabel2.textColor = color
        lastLabel1.textColor = color
        lastLabel2.textColor = color        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
