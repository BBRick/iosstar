//
//  GetOrderStarsVC.swift
//  iOSStar
//
//  Created by sum on 2017/5/9.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import MJRefresh

class GetOrderStarsVC: BaseCustomPageListTableViewController,OEZTableViewDelegate {
    @IBOutlet var nodaView: UIView!
    //选中 当前选择的cell
    var seleNumber = 10000000
    //当前未选择的cell
    var unseleNumber = 10000000
    var domeet = true
    var doRealm = false
    var scrollView: UIScrollView!
   
     // MARK: - viewload
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "持有明细"
        self.nodaView.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.getRealmStatus()
        
    }
    override func isSections() -> Bool {
        return true
    }
    func getRealmStatus(){
        self.getUserRealmInfo { (result) in
            if let model = result{
                let object =  model as! [String : AnyObject]
                
                if object["realname"] as! String == ""{
                    self.doRealm = true
                } else {
                    self.doRealm = false
                }
            }
        }
    }
    override func didRequest(_ pageIndex: Int) {
        //连接的明细
        if domeet{
            let requestModel = StarMailListRequestModel()
            requestModel.status = 1
            requestModel.startPos = (pageIndex - 1) * 10
            
            AppAPIHelper.user().requestStarMailList(requestModel: requestModel, complete: { (result) in
                let Model : StarListModel = result as! StarListModel
                self.didRequestComplete( Model.depositsinfo as AnyObject)
                self.tableView.reloadData()
                if (self.dataSource?.count == 0){
                    self.nodaView.isHidden = false
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 0)
                    self.tableView.reloadData()
                    
                }else{
                    self.nodaView.isHidden = true
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 385)
                    self.tableView.reloadData()
                }
            }) { (error ) in
                
                
                self.didRequestComplete(nil)
                if (self.dataSource?.count == nil || self.dataSource?.count == 0){
                    self.nodaView.isHidden = false
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 385)
                    self.tableView.reloadData()
                }else{
                    self.nodaView.isHidden = true
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 0)
                    self.tableView.reloadData()
                }
            }
        }
            //连接的情况
        else{
            let requestModel = StarMailOrderListRequestModel()
            requestModel.pos = (pageIndex - 1) * 10
            AppAPIHelper.user().requestOrderStarMailList(requestModel: requestModel, complete: { (result) in
                let Model  = result as! OrderStarListModel
                self.didRequestComplete( Model.list as AnyObject)
                self.tableView.reloadData()
                if (self.dataSource?.count == 0){
                    self.nodaView.isHidden = false
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 385)
                    self.tableView.reloadData()
                }else{
                    self.nodaView.isHidden = true
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 0)
                    self.tableView.reloadData()
                }
            }) { (error ) in
                self.didRequestComplete(nil)
                if (self.dataSource?.count == nil  || self.dataSource?.count == 0){
                    self.nodaView.isHidden = false
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 385)
                    self.tableView.reloadData()
                }else{
                    self.nodaView.isHidden = true
                    self.nodaView.frame =  CGRect.init(x: 0, y: 13, width: kScreenWidth, height: 0)
                    self.tableView.reloadData()
                }
            }
        }
    }
    func configScrollView(){
    
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if domeet{
            if seleNumber == indexPath.section{
                return 160
            }
            if unseleNumber == indexPath.section{
                return 65
            }
            return 65
        }
        
        return 65
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.count  == nil ? 0 : (self.dataSource?.count)!
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GetOrderStarsVCCell") as! GetOrderStarsVCCell
        if domeet{
            let model = self.dataSource?[indexPath.section] as! StarInfoModel
            cell.update(model)
            cell.dodetail.tag = indexPath.section
            cell.dodetail.addTarget(self , action: #selector(dostarDetail(_:)), for: .touchUpInside)
            cell.chatButton.transform = CGAffineTransform(rotationAngle: CGFloat(0));
            if seleNumber == indexPath.section{
                cell.chatButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            }
            
            if unseleNumber == indexPath.section{
                cell.chatButton.transform = CGAffineTransform(rotationAngle: CGFloat(0));
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListCell") as! ContactListCell
            let model = self.dataSource?[indexPath.section] as! OrderStarListInfoModel
            cell.update(model)
            cell.doStarDeatil.tag = indexPath.section
            cell.doStarDeatil.addTarget(self , action: #selector(dostar(_:)), for: .touchUpInside)
            cell.chatButton.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView!, rowAt indexPath: IndexPath!, didAction action: Int, data: Any!) {
        //连接
        if action == 4 {
             if doRealm{
                showRealname()
            }else{
                let model = self.dataSource?[indexPath.section] as! StarInfoModel
                let modeldata = StarSortListModel()
                
                StartModel.getStartName(startCode: model.starcode) { (response) in
                    if let star = response as? StartModel{
                        modeldata.pic_tail = star.pic_url_tail
                        modeldata.name = model.starname
                        modeldata.symbol = model.starcode
                        let story = UIStoryboard.init(name: "Market", bundle: nil)
                        let vc = story.instantiateViewController(withIdentifier: "OrderStarViewController") as! OrderStarViewController
                        vc.starInfo = modeldata
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        return
                    }
                }
                
            }
            
        }
        //聊天
        if action == 5 {
            if doRealm{
                showRealname()
            }else{
                let model = self.dataSource?[indexPath.section] as! StarInfoModel
                let session = NIMSession( model.faccid, type: .P2P)
                let vc = YDSSessionViewController(session: session)
                vc?.starcode = model.starcode
                vc?.starname = model.starname
                self.navigationController?.pushViewController(vc!, animated: true)
                self.tableView.reloadSections(IndexSet(integer: unseleNumber), with: .fade)
                return
            }
            
        }
        if unseleNumber != 10000000{
            self.tableView.reloadSections(IndexSet(integer: unseleNumber), with: .fade)
        }
        if seleNumber == indexPath.section{
            unseleNumber = seleNumber
            
            seleNumber = 10000000
            self.tableView.reloadSections(IndexSet(integer: unseleNumber), with: .fade)
            unseleNumber = 10000000
        }else{
            seleNumber = indexPath.section
            self.tableView.reloadSections(IndexSet(integer: seleNumber), with: .fade)
            
            unseleNumber = indexPath.section
        }
        
    }
    //MARK:- 进入网红详细资料
    func dostarDetail(_ sender : UIButton){
        let model = self.dataSource?[sender.tag] as! StarInfoModel
        StartModel.getStartName(startCode: model.starcode) { (response) in
            let star = response as? StartModel
            let starListModel = StarSortListModel()
            
            starListModel.symbol = model.starcode
            starListModel.name = model.starname
            starListModel.pic_tail  = (star?.pic_url_tail)!
            let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "StarIntroduceViewController") as! StarIntroduceViewController
            introVC.starModel = starListModel
            
            self.navigationController?.pushViewController(introVC, animated: true)
        }
        
    }
    func dostar(_ sender : UIButton){
        
        let starListModel = StarSortListModel()
        let model = self.dataSource?[sender.tag] as! OrderStarListInfoModel
        starListModel.symbol = model.star_code
        starListModel.name = model.star_name
        let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "StarIntroduceViewController") as! StarIntroduceViewController
        introVC.starModel = starListModel
        
        self.navigationController?.pushViewController(introVC, animated: true)
    }
    // MARK: -button点击事件
//    //选中的状态
//    @IBAction func orderStatus(_ sender: Any) {
//        domeet = false
//        seleNumber = 10000000
//        unseleNumber = 10000000
//        self.nodaView.isHidden = false
//        self.dataSource?.removeAll()
//        self.tableView.reloadData()
//        self.didRequest(1)
//        ownSecond.backgroundColor = UIColor.clear
//        orderStatus.backgroundColor = UIColor.init(hexString: "333333")
//    }
//    @IBAction func ownSecondInside(_ sender: Any) {
//        domeet = true
//        seleNumber = 10000000
//        unseleNumber = 10000000
//        self.nodaView.isHidden = false
//        self.dataSource?.removeAll()
//        self.tableView.reloadData()
//        self.didRequest(1)
//        orderStatus.backgroundColor = UIColor.clear
//        ownSecond.backgroundColor = UIColor.init(hexString: "333333")
//    }
    
    
}
