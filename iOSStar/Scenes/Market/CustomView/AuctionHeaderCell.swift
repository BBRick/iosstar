//
//  AuctionHeaderCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/22.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class AuctionHeaderCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    //顶部展示star图片
    @IBOutlet var showImageView: UIImageView!
    //当前持有此网红时间数量
    @IBOutlet weak var positionCount: UILabel!
    //网红名称以及代码
    @IBOutlet weak var starCodeLabel: UILabel!
    @IBOutlet weak var buyCountLabel: UILabel!
    
    @IBOutlet weak var sellCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var buyWidth: NSLayoutConstraint!
    //回收倒计时剩余时间
    @IBOutlet weak var timeLabel: UILabel!
    //回收委托总数据量占比
    @IBOutlet var sellProgressView: GradualColorView!
    @IBOutlet weak var countProgressView: GradualColorView!
    @IBOutlet var buyProgressView: GradualColorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showImageView.layer.masksToBounds = true
        countProgressView.percent = 0.5
        countProgressView.addGradualColorLayer(isRound:true)
        countProgressView.layer.cornerRadius = 8
        buyProgressView.isShowImage = false
        buyProgressView.percent = 1
        sellProgressView.isShowImage = false
        sellProgressView.percent = 1
        
        sellProgressView.completeColors = [UIColor(hexString: "4BE2C9"), UIColor(hexString: "BCE0DA")]
        buyProgressView.addGradualColorLayer(isRound:false)
        sellProgressView.addGradualColorLayer(isRound:false)
    
        sellProgressView.setCornoerRadius(byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 8.0, height: 8.0))
        buyProgressView.setCornoerRadius(byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 8.0, height: 8.0))
        backView.layer.cornerRadius = 3
        backView.backgroundColor = UIColor.init(hexString: AppConst.Color.orange)
    }
    func setPercent(model:BuySellCountModel?,totalCount:Int) {
        guard model != nil else {
            return
        }
        
        buyCountLabel.text = "买入：\(model!.buyCount)人"
        sellCountLabel.text = "卖出：\(model!.sellCount)人"

        let all = CGFloat(model!.buyCount + model!.sellCount)
        if all != 0 {


            if model!.buyCount == 0 {
                sellProgressView.setCornoerRadius(byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 8.0, height: 8.0))
            } else {
                sellProgressView.setCornoerRadius(byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 8.0, height: 8.0))
            }
            if model!.sellCount == 0 {
                buyProgressView.setCornoerRadius(byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 8.0, height: 8.0))
            } else{
                buyProgressView.setCornoerRadius(byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 8.0, height: 8.0))
            }
            let percent = CGFloat(model!.buyCount) / CGFloat(model!.buyCount + model!.sellCount)
            buyWidth.constant = (kScreenWidth - 50) * percent

 
        } else {
            sellProgressView.setCornoerRadius(byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 8.0, height: 8.0))

            buyProgressView.setCornoerRadius(byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 8.0, height: 8.0))

            buyWidth.constant = (kScreenWidth - 50) * 0.5
        }

        

        //buyProgressView.animation(percent: 1)
        //sellProgressView.animation(percent: 1)
        var timePercent:CGFloat = 0.5
        if model!.sellTime > totalCount {
            timePercent =  CGFloat(totalCount == 0 ? 1 : totalCount) / CGFloat(model!.sellTime)
        } else {
            timePercent = CGFloat(model!.sellTime) / CGFloat(totalCount == 0 ? 1 : totalCount)
        }
        //countProgressView.animation(percent: timePercent)
        totalCountLabel.text = "总计：\(totalCount)秒"
        
    }
    
    func setTimeText(text:String) {
        
        if text == "回收未开始" {
            timeLabel.text = text
        } else {
            timeLabel.setAttributeText(text: "剩余回收时间: \(text)", firstFont: 16, secondFont: 16, firstColor: UIColor(hexString: "333333"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 8, length: text.length()))
        }
    }
    func setImageUrl(url:String)  {

        showImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + url))
    }
    
    func setPositionCountModel(model:PositionCountModel?, starCode:String?, starName:String?) {
        

        if model != nil {
            positionCount.text = "\(model!.star_time)秒"
        }
        if  starCode != nil && starName != nil {
            starCodeLabel.text = "已持有\(starName!)(\(starCode!))"
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
