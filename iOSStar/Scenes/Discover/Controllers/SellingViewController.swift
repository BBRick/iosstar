//
//  SellingViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/8.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class SellingViewController: UIViewController {
    @IBOutlet weak var sureBuyButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var needPwd: Int = 0
    //倒计时剩余时间
    var remainingTime = 0
    
    var starInfoModel:PanicBuyInfoModel?
    var countTf = UITextField()
    var starModel:StarSortListModel?
    var sectionHeights = [200, 70, 50, 65, 60, 50]
    var identifiers = [SellingIntroCell.className(), SellingTimeAndCountCell.className(), SellingCountDownCell.className(), SellingBuyCountCell.className(), SellingPriceCell.className(), SellingTipsCell.className()]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发售"
        setPriceWithPrice(price: 0)
        requestRemainTime()
        requestPanicBuyStarInfo()

        YD_CountDownHelper.shared.countDownRefresh = {  [weak self] (result) in
            

            if self!.remainingTime > 0 {
                
                self?.remainingTime -= 1
            }
            
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SellingCountDownCell {
                cell.setRemainingTime(count: self!.remainingTime)
            }
            
            
        }
        YD_CountDownHelper.shared.start()
    }
    deinit {
        YD_CountDownHelper.shared.countDownRefresh = nil    
    }
    
    func setPriceWithPrice(price:Double) {

        guard starModel != nil else {
            return
        }
        if starModel!.pushlish_type == 0 {
            sureBuyButton.setTitle("预售", for: .normal)
            sureBuyButton.backgroundColor = UIColor.gray
            sureBuyButton.isUserInteractionEnabled = false
        }
        let priceString = String(format: "%.2f", price)
        let text = "合计: ￥\(priceString)"
        
        totalPriceLabel.setAttributeText(text: text, firstFont: 16, secondFont: 16, firstColor: UIColor(hexString: "333333"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 4, length: text.length() - 4))
        
        totalPriceLabel.setNeedsDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.HideLine()
        self.getUserInfo { (result) in
            if let response = result{
                let object = response as! UserInfoModel
              
                self.needPwd = object.is_setpwd
            }
        }
    }
    func requestRemainTime() {
        guard starModel != nil else {
            return
        }
        
        let requestModel = BuyRemainingTimeRequestModel()
        requestModel.symbol = starModel!.symbol
        AppAPIHelper.discoverAPI().requestBuyRemainingTime(requestModel: requestModel, complete: { (response) in
            
            if let model = response as? BuyRemainingTimeModel {
                self.remainingTime = Int(model.remainingTime)
            }
        }) { (error) in
            
        }
    }
    
    func requestPanicBuyStarInfo() {
        guard starModel != nil else {
            return
        }
        let requestModel = PanicBuyRequestModel()
        requestModel.symbol = starModel!.symbol
        AppAPIHelper.discoverAPI().requsetPanicBuyStarInfo(requestModel: requestModel, complete: { (response) in
    
            if let model = response as? PanicBuyInfoModel {
                self.starInfoModel = model
                if let workStr = self.starModel?.work {
                    self.starInfoModel?.work = workStr
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
        
        
    }

    @IBAction func buyAction(_ sender: Any) {
        
        guard starModel != nil else {
            return
        }
        guard countTf.text != "" else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入购买数量", ForDuration: 1, completion: nil)
            return
        }
        if ( Int64.init(countTf.text!)!) == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "购买数量大于0", ForDuration: 1, completion: nil)
            return
        }
        else if ( ( Int64.init(countTf.text!)!) > (starInfoModel?.publish_last_time)!){
            SVProgressHUD.showErrorMessage(ErrorMessage: "最多购买"  + "\(String(describing: starInfoModel!.publish_last_time))" + "秒", ForDuration: 1, completion: nil)
            return

        }
        tradePass()
        
       
    }
    func dodetail(){
        let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "StarIntroduceViewController") as! StarIntroduceViewController
//        let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "IntroduceTableVC") as! IntroduceTableVC
        introVC.starModel = starModel
        self.navigationController?.pushViewController(introVC, animated: true)

        
    }
}

extension SellingViewController:UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.tableView.contentOffset = CGPoint(x: 0, y: 200)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sectionHeights[indexPath.row])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func countChange(sender:UITextField) {
        if sender.text != nil {
            if let price = Double(sender.text!) {
                setPriceWithPrice(price: price * (starInfoModel?.publish_price ?? 0))
                
            }
        } else {
            setPriceWithPrice(price: 0)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiers[indexPath.row]!, for: indexPath)
        switch indexPath.row {
        case 2:
            if let countDownCell = cell as? SellingCountDownCell {
                countDownCell.setRemainingTime(count:remainingTime)
            }
        case 0:
            if let introCell = cell as? SellingIntroCell {
                introCell.doDetail.addTarget(self , action: #selector(dodetail), for: .touchUpInside)
            }
        case 3:
            if let buyCountCell = cell as? SellingBuyCountCell {
                buyCountCell.countTextField.delegate = self
                countTf = buyCountCell.countTextField
                buyCountCell.countTextField.addTarget(self, action: #selector(countChange(sender:)), for: .editingDidEnd)
              
            }
        case 5:
            if let tipsCell = cell as? SellingTipsCell {
                return tipsCell
            }
        default:
            break
        }
        if let baseCell = cell as? SellingBaseCell {
            baseCell.setPanicModel(model: starInfoModel)
        }
        return cell
    }
    func tradePass(){
    
        
        if self.needPwd == 1{
            let alertVc = AlertViewController()
            alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                                
                                titleLabelText: "开通支付",
                                subTitleText: "需要开通支付才能进行充值等后续操作。\n开通支付后，您可以获取网红时间，回收网红时间，\n和网红在‘连接网红’中聊天，并且还能连接网红。",
                                completeButtonTitle: "我 知 道 了") {[weak alertVc] (completeButton) in
                                    alertVc?.dismissAlertVc()
                                    
                                    
                                    let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "TradePassWordVC")
                                    self.navigationController?.pushViewController(vc, animated: true )
                                    return
            }
        }else{
        
        let model = OrderInformation()
        model.orderStatus = "购买"
        model.orderInfomation = String.init(format: "%@ (%@)秒", (self.starInfoModel?.star_name)! ,(countTf.text)!)
        model.orderPrice =  String.init(format: "%.2f/秒", (self.starInfoModel?.publish_price)!)
        model.ordertitlename = "订单详情"
        //将值传给 sharedatemodel
        ShareDataModel.share().orderInfo = model
        let storyboard = UIStoryboard.init(name: "Order", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as!  UINavigationController
        
        
        let rootvc = controller.viewControllers[0] as! ContainPayVC
        
        rootvc.showAll = false
        
        rootvc.resultBlock = { (result) in
            
            if result is String{
                SVProgressHUD.showSuccessMessage(SuccessMessage: "密码校验成功", ForDuration: 0.5, completion: {
                   self.dosell()
                    controller.dismissController()
                    
                })
                
            }
            else{
                SVProgressHUD.showErrorMessage(ErrorMessage:  "购买已取消", ForDuration: 2, completion: nil)
            }
        }
        controller.modalPresentationStyle = .custom
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
        }
    }
    func dosell(){
        let requestModel = BuyStarTimeRequestModel()
        requestModel.amount = Int64.init(countTf.text!)!
        requestModel.price = (self.starInfoModel?.publish_price)!
        requestModel.symbol = starModel!.symbol
        
        AppAPIHelper.discoverAPI().buyStarTime(requestModel: requestModel, complete: { (response) in
            if let result = response as? Int{
                if result == 1{
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功", ForDuration: 1, completion: {
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                }else{
                    SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
                }
            }else{
                SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
            }
        }) { (error) in
            self.didRequestError(error)
            //            SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
            
        }
    }


}
