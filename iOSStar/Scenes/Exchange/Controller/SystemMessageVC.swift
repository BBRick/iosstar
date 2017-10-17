//
//  SystemMessageVC.swift
//  iOSStar
//
//  Created by sum on 2017/5/24.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class MessageCell:  OEZTableViewCell{
    
    @IBOutlet var time_lb: UILabel!
    @IBOutlet var content: UILabel!
    @IBOutlet var dosee: UIButton!
    override func update(_ data: Any!) {
        
        let model = data as! OrderListModel
        //001 100 101 011 110
        // print("===\(model)")
        
        var title = ""
        var colorString = ""
        let userId = StarUserModel.getCurrentUser()?.userinfo?.id
        StartModel.getStartName(startCode: model.symbol) { (result) in
            let data = result as! StartModel
            let str = model.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id ? "回收":"获取"
            self.content.text = "\(data.name)" +  " " + "(" + "\(data.code)" + ")" +  " " + str
        }
        
        time_lb.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(model.openTime), format: "YY-MM-dd HH:mm")
        if model.handle == 0 {
            if ((model.buyUid == userId && model.buyHandle == 0 && model.sellHandle == 1) || (model.sellUid == userId && model.sellHandle == 0 && model.buyHandle == 1)){
                title = "未确认"
                colorString = AppConst.Color.orange
            } else  if ((model.buyUid == userId && model.sellHandle == 0 && model.buyHandle == 0) || (model.sellUid == userId && model.sellHandle == 0 && model.buyHandle == 0)){
                title = "未确认"
                colorString = AppConst.Color.orange
            }  else {
                title = "订单生成"
                colorString = "333333"
            }
        } else if model.handle == 1{
            
            if ((model.buyUid == userId && model.buyHandle == 1  && model.sellHandle == 0) || (model.sellUid == userId && model.sellHandle == 1 && model.buyHandle == 0)){
                title = "已确认"
                colorString = "333333"
            } else if ((model.buyUid == userId && model.buyHandle == 0 && model.sellHandle == 1) || (model.sellUid == userId && model.sellHandle == 0 && model.buyHandle == 1)){
                title = "未确认"
                colorString = AppConst.Color.orange
            } else  if ((model.buyUid == userId && model.sellHandle == 0 && model.buyHandle == 0) || (model.sellUid == userId && model.sellHandle == 0 && model.buyHandle == 0)){
                title = "已确认"
                colorString = AppConst.Color.orange
            } else {
                title = "订单生成"
                colorString = "333333"
            }
        } else if model.handle == -1{
            title = "订单取消"
            colorString = "333333"
        } else if model.handle == -2{
               title = "对方时间不足"
            if model.sellUid == userId {
                title = "您时间不足"
            }
            colorString = "333333"
        } else if model.handle == -3{
             title = "对方金额不足"
            if model.buyUid == userId {
              title = "您金额不足"
            }
            colorString = "333333"
        } else if model.handle == -4{
            title = "交易失败"
            colorString = "333333"
        } else if model.handle == 2{
            title = "交易完成"
            colorString = "333333"
        } else {
            title = "交易完成"
            colorString = "333333"
        }
        dosee.setTitle(title, for: .normal)
        dosee.setTitleColor(UIColor.init(hexString: colorString), for: .normal)
        
    }

    
}
class SystemMessageVC: BasePageListTableViewController {

    @IBOutlet var nodata: UIView!
    var frame : CGRect? = nil
    var needPwd : Int = 2
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "系统消息"
        tableView.separatorStyle = .none
        self.nodata.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(leftButtonItemClick(_ :)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.getUserInfo { [weak self](result) in
            if let response = result{
                let object = response as! UserInfoModel
                self?.needPwd = object.is_setpwd
               
            }
        
        }

    }
    
    // 判断是被push还是被modal出来的;
    func leftButtonItemClick(_ sender : Any) {
        
        let vcs = self.navigationController?.viewControllers
        
        guard vcs != nil else { return }
        
        if vcs!.count > 1{
            // push过来的
            if vcs?[vcs!.count - 1] == self {
                _ = navigationController?.popViewController(animated: true)
            }
        } else {
            // modal
                self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }

    override func didRequest(_ pageIndex: Int) {
        if self.dataSource?.count != nil && (self.dataSource?.count)! >= 0 {
            self.nodata.isHidden = true
//            self.nodata.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
            tableView.reloadData()
        }
        let model = OrderRecordRequestModel()
        model.status = 3
        model.start = Int32((pageIndex - 1) * 10)
        model.count = 10
      AppAPIHelper.dealAPI().requestOrderList(requestModel: model, OPCode: .historyOrder, complete: { (result) in
         if  let object = result {
            
            self.didRequestComplete(object)
            if self.dataSource?.count == 0{
            self.nodata.isHidden = false
            }else{
             self.nodata.isHidden = true
//              = CGRect.init(x: 0, y: 0, width: 0, height: 0)
                self.tableView.reloadData()
            }
        }
    }) { (error ) in
         self.didRequestComplete(nil)
        if self.dataSource?.count == 0 || self.dataSource == nil{
            self.nodata.isHidden = false
        }else{
            self.nodata.isHidden = true
//            self.nodata.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
               self.tableView.reloadData()
        }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        if self.needPwd == 1 {
//            let alertVc = AlertViewController()
//            alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
//                                
//                                titleLabelText: "开通支付",
//                                subTitleText: "需要开通支付才能进行充值等后续操作。\n开通支付后，您可以获取网红时间，回收网红时间，\n和网红在‘连接网红’中聊天，并且还能连接网红。",
//                                completeButtonTitle: "我 知 道 了") {[weak alertVc] (completeButton) in
//                                    alertVc?.dismissAlertVc()
//                                    let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "TradePassWordVC")
//                                    self.navigationController?.pushViewController(vc, animated: true )
//                                    return
//            }
//            return
//        }
//        else
//        {
        let  data = self.dataSource?[indexPath.row] as! OrderListModel
        if (data.handle == 0) {
            if ((data.buyUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.buyHandle == 0) || (data.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.sellHandle == 0) ){
                let alertController = UIAlertController(title: "交易提醒", message: "点击确认进行交易,请仔细阅读设置中的法律说明", preferredStyle:.alert)
                let cancelAction = UIAlertAction(title: "取消", style:.default) { (UIAlertAction) in
                    self.doorder(data, true)
                }
                let completeAction = UIAlertAction(title: "确定", style:.default) { (UIAlertAction) in
                    self.doorder(data, false)
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(completeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }else if (data.handle == 1) {
            
            if ((data.buyUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.buyHandle == 1  && data.sellHandle == 0) || (data.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.sellHandle == 1 && data.buyHandle == 0)){
            
            }else  if ((data.buyUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.sellHandle == 0) || (data.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id && data.sellHandle == 0)){
                let alertController = UIAlertController(title: "交易提醒", message: "点击确认进行交易,请仔细阅读设置中的法律说明", preferredStyle:.alert)
                let cancelAction = UIAlertAction(title: "取消", style:.default) { (UIAlertAction) in
                    self.doorder(data, true)
                }
                let completeAction = UIAlertAction(title: "确定", style:.default) { (UIAlertAction) in
//                    self.doorder(data, false)
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(completeAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        // print(indexPath.section)
        cell.update(dataSource?[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 3 : 0.001
    }
     override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func doorder(_ order : OrderListModel,_ canel : Bool)  {
        
        if canel{
            let sure = CancelOrderRequestModel()
            sure.orderId = order.orderId
            
            AppAPIHelper.dealAPI().cancelOrderRequest(requestModel: sure, complete: { (result) in
                if let object = result as? [String : Any]  {
                    self.didRequest(1)
                    if let status = object["status"] as? Int{
                        if status == 0{
                               self.didRequest(1)
                            SVProgressHUD.showSuccess(withStatus: "取消成功")
    
                       }
                    }
                }
            }, error: { (error ) in
                self.didRequest(1)
               SVProgressHUD.showErrorMessage(ErrorMessage: error.userInfo["NSLocalizedDescription"]  as! String, ForDuration: 2, completion: nil )
            })
        }else{
            let sure = SureOrderRequestModel()
            sure.orderId = order.orderId
            sure.positionId = order.positionId
            AppAPIHelper.dealAPI().sureOrderRequest(requestModel: sure, complete: { (result) in
                if let object = result as? [String : Any]  {
                
                    self.didRequest(1)
                    if let status = object["status"] as? Int{
                        if status == 0{
                               self.didRequest(1)
                            SVProgressHUD.showSuccess(withStatus: "确认成功")
                        }
                    }
                }
            }, error: { (error) in
                self.didRequest(1)
                SVProgressHUD.showErrorMessage(ErrorMessage: error.userInfo["NSLocalizedDescription"] as! String, ForDuration: 2, completion: nil )
            })
        }

    }
    func showView(_ order : OrderListModel,_ canel : Bool){
        let model = OrderInformation()
        let aa = order.openPrice * Double.init(order.amount)
        let float = "\(aa)"
        model.orderAllPrice = "\(float)"
        model.orderAccount = "\(order.amount)"
        if order.openPrice < 0{
         model.orderPrice = "\(-order.openPrice)"
            
            let aa = order.openPrice * Double.init(order.amount)
            let float = "\(-aa)"
            model.orderAllPrice = "\(float)"
        }else{
          model.orderPrice = "\(order.openPrice)"
        }
       
        model.orderStatus  = order.sellUid == StarUserModel.getCurrentUser()?.userinfo?.id ? "回收":"获取"
        StartModel.getStartName(startCode: order.symbol) { (result) in
            let data = result as! StartModel
            model.orderInfomation = "\(data.name)" + "(" + "\(data.code)" + ")"
        }    
        //将值传给 sharedatemodel
        ShareDataModel.share().orderInfo = model
        let storyboard = UIStoryboard.init(name: "Order", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as!  UINavigationController
        
        let rootvc = controller.viewControllers[0] as! ContainPayVC
        
        rootvc.resultBlock = { (result) in
            
        SVProgressHUD.showSuccessMessage(SuccessMessage: "密码校验成功", ForDuration: 0.5, completion: {
                if canel {
                            self.doorder(order, true)
                        }else{
                            self.doorder(order, false)
                        }
            controller.dismissController()
        })
            
        }
        controller.modalPresentationStyle = .custom
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
}
