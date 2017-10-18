//
//  BuyOrSellViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/22.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class BuyOrSellViewController: DealBaseViewController {
    var identifiers = ["DealStarInfoCell","DealMarketCell","DealOrderInfoCell"]
    var rowHeights = [137, 100,133,82]
    var infos:[String] = ["回收价格","回收数量"]
    var count = 600
    var price = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var buyOrSellButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        
        if dealType == AppConst.DealType.buy {
            infos  = ["获取价格","获取数量"]
            buyOrSellButton.setTitle("确认获取", for: .normal)
        } else {
            infos = ["回收价格","回收数量"]
            buyOrSellButton.setTitle("确认回收", for: .normal)
        }

        if realTimeData != nil {
            let price = String(format: "%.2f", realTimeData!.currentPrice)
            priceDidChange(totalPrice: Double(price)! * Double(600), count: 600, price: Double(price)!)
        } else {
            requestRealTime()
        }
//       requestPositionCount()
       requetTotalCount()
    }
    
    
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    func keyboardWillShow(notification: NSNotification?) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: -150, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    
    func requetTotalCount() {
        guard starListModel != nil else {
            return
        }
        let param = MiuCountRequestModel()
        param.star_code = starListModel!.symbol
        AppAPIHelper.dealAPI().requestMiuCount(requestModel: param, complete: { [weak self](response)in
            if let model = response as? MiuResponeModel {
                self?.totalCount = model.star_own_time
                self?.positionCount = model.user_star_time
                self?.tableView.reloadData()
            }
        }, error: nil)
//        tAPI().requestTotalCount(starCode: starListModel!.symbol, complete: { (response) in
//            if let model = response as? StarTotalCountModel {
//                self.totalCount = Int(model.star_time)
//            }
//            
//        }) { (error) in
//            
//            
//        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buyOrSellAction(_ sender: Any) {

        
        if starListModel == nil  {
            return
        }

        guard price != 0.0 else{
            SVProgressHUD.showErrorMessage(ErrorMessage: "输入价格大于0", ForDuration: 1.5, completion: nil)
            return
        }
     

        if count > totalCount && dealType == AppConst.DealType.buy{
            SVProgressHUD.showErrorMessage(ErrorMessage: "获取数量不能超过总发行量", ForDuration: 1.5, completion: nil)
            return
        }
        
        if count > positionCount && dealType == AppConst.DealType.sell{
            SVProgressHUD.showErrorMessage(ErrorMessage: "回收数量不能超过当前总持有量", ForDuration: 1.5, completion: nil)
            return
        }
        

        SVProgressHUD.show()
        let model = BuyOrSellRequestModel()
        model.buySell = dealType.rawValue
        model.symbol = starListModel!.symbol
        model.price = price
        model.amount = count
        AppAPIHelper.dealAPI().buyOrSell(requestModel: model, complete: {[weak self] (response) in
            SVProgressHUD.showSuccessMessage(SuccessMessage: "挂单成功", ForDuration: 2, completion: {
                DispatchQueue.main.async {
                    let index = 3
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sellScucess"), object: nil, userInfo:nil)
                    self?.indexBlock!(index as AnyObject)
                }
            })
        }) { (error) in
            SVProgressHUD.dismiss()
        }
        
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YD_CountDownHelper.shared.marketTimeLineRefresh = nil

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        YD_CountDownHelper.shared.marketTimeLineRefresh = { [weak self] (result)in
            self?.requestRealTime()
        }
    }

    func requestRealTime() {
        let requestModel = RealTimeRequestModel()
        let syModel = SymbolInfo()
        if starListModel != nil {
            syModel.symbol = starListModel!.wid
        } else  {
            return
        }
        requestModel.symbolInfos.append(syModel)
        AppAPIHelper.marketAPI().requestRealTime(requestModel: requestModel, complete: { (response) in
            if let model = response as? [RealTimeModel] {
                self.realTimeData = model.first
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        }) { (error) in
            
            
        }
    }
    
    func requestPositionCount() {
        guard starListModel != nil else {
            return
        }
        
        let r = PositionCountRequestModel()
        r.starcode = starListModel!.symbol
        AppAPIHelper.marketAPI().requestPositionCount(requestModel: r, complete: { (response) in
            if let model = response as? PositionCountModel {
                self.positionCount = Int(model.star_time)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }) { (error) in

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowEntrustListViewController {
            vc.starCode = starListModel?.symbol
        }
    }
}

extension BuyOrSellViewController:UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, OrderInfoChangeDelegate,ShowEntrustDelegate{
    
    func show() {
        let storyBoard = UIStoryboard(name: "Market", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MarketFansListViewController") as? MarketFansListViewController
        vc?.starCode = starListModel?.symbol
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    func priceDidChange(totalPrice: Double, count: Int, price: Double) {
    
        let priceString = String(format: "%.2f", totalPrice)
        orderPriceLabel.setAttributeText(text: "总价：\(priceString)", firstFont: 18, secondFont: 18, firstColor: UIColor(hexString: "999999"), secondColor: UIColor(hexString: AppConst.Color.lightAction), range: NSRange(location: 3, length: priceString.length()))
        self.count = count
        self.price = price
        if totalPrice == 0 {
            buyOrSellButton.isUserInteractionEnabled = false
            buyOrSellButton.backgroundColor = UIColor(hexString: "CCCCCC")
        } else {
            buyOrSellButton.isUserInteractionEnabled = true
            buyOrSellButton.backgroundColor = UIColor(hexString: AppConst.Color.main)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
//        view.y = 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeights[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiers[indexPath.row], for: indexPath)
        
        switch indexPath.row {
        case 0:
            if let infoCell = cell as? DealStarInfoCell{
                infoCell.delegate = self
                infoCell.setupData(model:starListModel)
                infoCell.setCount(count:positionCount)
            }
        case 1:
            if let marketCell = cell as? DealMarketCell {
                marketCell.setRealTimeData(model: realTimeData)
            }
        case 2:
            if let orderCell = cell as? DealOrderInfoCell {
                orderCell.count = 600
                orderCell.delegate = self
                orderCell.setTitles(titles: infos)
                guard realTimeData != nil else {
                    return orderCell
                }
                orderCell.price = price
                orderCell.setPriceAndCount(price:price, count:count)
            }
        case 3:
            if let showCell = cell as? DealHintCell {
                showCell.delegate = self
            }
        default:
            break   
        }
        return cell
    }
}
