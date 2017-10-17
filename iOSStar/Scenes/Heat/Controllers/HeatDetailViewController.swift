
//
//  HeatDetailViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/16.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import BarrageRenderer

class HeatDetailViewController: UIViewController {
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var ballImageView: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var backImageVIew: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var iconImageVie: UIImageView!
    @IBOutlet weak var width: NSLayoutConstraint!
    
    let test = false
    var statusModel:AuctionStatusModel?
    var imageName = "starList_back0"
    var starListModel:StarSortListModel?
    var endTime:Int64 = 0
    var index = 0
    var fansList:[FansListModel]?
    
    lazy var renderer: BarrageRenderer = {
        let renderer = BarrageRenderer()
        renderer.canvasMargin = UIEdgeInsets(top: -100, left: 0, bottom: 100, right: 0)
        renderer.view.backgroundColor = UIColor.clear
        return renderer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "时间回购"
        view.addSubview(renderer.view)
        backImageVIew.clipsToBounds = true
        setData()
        width.constant = kScreenWidth
        setupNav()
        buyButton.layer.cornerRadius = 25
        sellButton.layer.cornerRadius = 25
        YD_CountDownHelper.shared.barrageRefresh = { (result)in

            var fans:FansListModel?
            if self.fansList?.count ?? 0 > self.index {
                fans = self.fansList?[self.index]
            } else if self.test {
                fans = FansListModel()
                let user = FansInfoModel()
                user.nickname = ""
                user.headUrl = "http://tva2.sinaimg.cn/crop.0.0.180.180.180/71bf6552jw1e8qgp5bmzyj2050050aa8.jpg"
                fans?.user = user
                let tra = FansTradesModel()
                tra.openPrice = 1.12
                fans?.trades = tra
            } else {
                self.ballImageView.alpha = 1.0

            }
            if fans == nil{
                return
            }
            self.renderer.receive(self.walkTextSpriteDescriptorWithDirection(direction: 0, data: fans!))
        }
        
        initCountDownBlock()
        requestFansList(buySell:-1)
        requestAuctionSattus()
        requestStarPrice()
        ballImageView.alpha = 0.5
    }
    
    func walkTextSpriteDescriptorWithDirection(direction:UInt,data : FansListModel) -> BarrageDescriptor{
        
        let descriptor:BarrageDescriptor = BarrageDescriptor()
        descriptor.spriteName = NSStringFromClass(YD_BarrageSprite.self)
        descriptor.params["imageUrl"] = data.user?.headUrl
        descriptor.params["name"] = data.user?.nickname
        descriptor.params["price"] = data.trades?.openPrice
        descriptor.params["isSell"] = data.trades?.buySell
        descriptor.params["speed"] = Int(arc4random()%30) + 50
        descriptor.params["direction"] = direction
        descriptor.params["amount"] = data.trades?.amount
        return descriptor
    }

    
    func requestFansList(buySell:Int32) {
        
        guard starListModel != nil else {
            return
        }
        let requestModel = FanListRequestModel()
        requestModel.buySell = buySell
        requestModel.star_code = starListModel!.symbol
        AppAPIHelper.marketAPI().requestBarrEntrustFansList(requestModel: requestModel, complete: { (response) in
            if let models = response as? [FansListModel]{
                if self.fansList == nil {
                    self.fansList = models
                } else {
                    self.fansList?.append(contentsOf: models)
                }
            }
        }, error: nil)
    }
    
    func requestStarPrice() {
        guard starListModel != nil else {
            return
        }
        let param = StarRealtimeRequestModel()
        param.starcode = starListModel!.symbol
        AppAPIHelper.marketAPI().requestStarRealTime(requestModel: param, complete: { [weak self](result) in
            if let model = result as? StarSortListModel{
                self?.priceLabel.text =  model.currentPrice > 0 ? String.init(format: "%.2f", model.currentPrice) : ""
            }
        }, error: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarBgAlpha = 0.0
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white];
        requestFansList(buySell:1)
        requestFansList(buySell:-1)
        YD_CountDownHelper.shared.start()
        renderer.start()
        
//        if let _ = UserDefaults.standard.value(forKey: AppConst.guideKey.timeBusiness.rawValue) as? String {
//            
//        }else{
//            showGuideVC(.timeBusiness, handle: { (vc)in
//                if let guideVC = vc as? GuideVC{
//                    if guideVC.guideType == AppConst.guideKey.timeBusiness{
//                        guideVC.dismiss(animated: true, completion:nil)
//                        UserDefaults.standard.set("ok", forKey: AppConst.guideKey.timeBusiness.rawValue)
//                        return
//                    }
//                    
//                }
//            })
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        YD_CountDownHelper.shared.pause()
        renderer.pause()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(hexString: AppConst.Color.main)];
    }

    //跳骚市场
    @IBAction func fleaMarket(_ sender: Any) {
        if checkLogin(){
             self.performSegue(withIdentifier: "pushbarr", sender: nil)
        }
    }

    func back() {
       _ = navigationController?.popViewController(animated: true)
    }

    func setupNav() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named:"white_back"), for: .normal)
        button.tintColor = UIColor(hexString: AppConst.Color.main)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let item = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationItem.leftBarButtonItem = item
    }
    
    func requestAuctionSattus() {
        guard starListModel != nil else {
            return
        }
        let model = AuctionStatusRequestModel()
        model.symbol = starListModel!.symbol
        AppAPIHelper.marketAPI().requestAuctionStatus(requestModel: model, complete: { (response) in
            if let model = response as? AuctionStatusModel {
                self.statusModel = model
                self.refreshSatus()
            }
        }, error: nil)
    }
    
    func setData() {
        backImageVIew.image = UIImage(named: imageName)
        iconImageVie.layer.borderColor = UIColor.white.cgColor
        iconImageVie.layer.borderWidth = 1
        priceLabel.text = starListModel?.currentPrice ?? 0 > 0 ? String(format: "%.2f", starListModel?.currentPrice ?? 0) : ""

        iconImageVie.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + (starListModel?.pic_tail)! ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        nameLabel.text = starListModel?.name
        jobLabel.text = starListModel?.work
    }
    
    func refreshSatus() {
        guard  statusModel != nil else {
            return
        }
        if statusModel!.status && statusModel!.remainingTime > 0 {
            endTime = Int64(Date().timeIntervalSince1970) + statusModel!.remainingTime
        }
    }
    
    func initCountDownBlock() {
        YD_CountDownHelper.shared.countDownRefresh = { [weak self] (result)in
            guard self != nil  else {
                return
            }
            self!.countDownLabel.text = YD_CountDownHelper.shared.getTextWithStartTime(closeTime: Int(self!.endTime))
        }
    }
    
    deinit {
        renderer.stop()
    }
    
    @IBAction func buyAction(_ sender: Any) {
        if checkLogin(){
         pushToDealPage(index: 0)
        }
    }
    
    @IBAction func sellAction(_ sender: Any) {
        if checkLogin(){
             pushToDealPage(index: 1)
        }
       
    }
    
    @IBAction func doPushStarDeatil(_ sender: Any) {
        if checkLogin(){
            let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "StarIntroduceViewController") as! StarIntroduceViewController
            introVC.starModel = starListModel
            self.navigationController?.pushViewController(introVC, animated: true)
        }
        
    }

    func pushToDealPage(index:Int) {
        if checkLogin() {
            let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Deal.rawValue, bundle: nil)
            if let vc = storyBoard.instantiateViewController(withIdentifier: "DealViewController") as? DealViewController {
                vc.index = index
                vc.starListModel = starListModel
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
