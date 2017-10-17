//
//  ResultVC.swift
//  iOSStar
//
//  Created by sum on 2017/5/24.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class ResultVC: UITableViewController {

    //网红的图片
    @IBOutlet weak var img: UIImageView!
    // 标题信息
    @IBOutlet weak var titleInfo: UILabel!
    //金额
    @IBOutlet weak var money: UILabel!
    //状态
    @IBOutlet weak var status: UILabel!
    //银行
    @IBOutlet weak var bank: UILabel!
    //创建时间
    @IBOutlet weak var create: UILabel!
    //设置手续费具体金额
    @IBOutlet weak var feeMoney: UILabel!
    //创建时间
    @IBOutlet weak var creteTime: UILabel!
    //银行名称
    @IBOutlet weak var bankInfo: UILabel!
    //手续费
    @IBOutlet weak var feedBack: UILabel!
    
    var responseData : Any?
    
    var rechargeStatus:[Int8 : String] = [1:"处理中", 2:"充值成功", 3:"充值失败",4:"用户取消"]
    var rechargeType:[Int8 : String] = [1:"微信支付", 2:"银行卡支付", 3:"支付宝支付"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账单详情"

        setupData()
    
        self.tableView.tableFooterView = UIView()
    }

    // recharge_type == 0 + 充值记录
    // recharge_type == 1 - 连接记录
    // recharge_type == 2 - 聊天记录
    func setupData() {
        
        //  获取上个界面传过来的model
        let model = self.responseData as! Model

        if model.recharge_type == 0 {
            
            if model.depositType == 1 {
                img.image = UIImage(named: "fukuanxuanxiang_weixin")
            } else if model.depositType == 2 {
                img.image = UIImage(named: "银行卡")
            } else {
                img.image = UIImage(named: "支付宝")
            }
            titleInfo.text = rechargeType[model.depositType]
            money.text = "+" + String.init(format: "%.2f", model.amount)
            status.text = rechargeStatus[model.status]
            bank.text = "支付信息"
            bankInfo.text = titleInfo.text
            
        } else if model.recharge_type == 1 {
            
            var starName = ""
            var pic_url_tail = ""
            StartModel.getStartName(startCode: model.transaction_id, complete: { (star) in
                if let starModel = star as? StartModel {
                    starName = starModel.name
                    pic_url_tail = starModel.pic_url_tail
                }
            })

            img.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + pic_url_tail))
            titleInfo.text = starName
            money.text = "-" + String.init(format: "%d秒", Int(model.amount))
            status.text = "连接"
            bank.text = "发行人信息"
            bankInfo.text = String.init(format: "%@ (%@)", starName,model.transaction_id)
        } else {
            
            var starName = ""
            var pic_url_tail = ""
            StartModel.getStartName(startCode: model.transaction_id, complete: { (star) in
                if let starModel = star as? StartModel {
                    starName = starModel.name
                    pic_url_tail = starModel.pic_url_tail
                }
            })

            img.kf.setImage(with:URL(string:ShareDataModel.share().qiniuHeader + pic_url_tail))
            titleInfo.text = starName
            money.text = "-" + String.init(format: "%d秒", Int(model.amount))
            status.text = "连接网红"
            bankInfo.text = String.init(format: "%@ (%@)", starName,model.transaction_id)
            bank.text = "发行人信息"
        }
        let timestr : Int = Date.stringToTimeStamp(stringTime: model.depositTime)
        self.creteTime.text = Date.yt_convertDateStrWithTimestempWithSecond(timestr, format: "yyyy-MM-dd")

    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)//点击完成，取消高亮
    }

   
}
