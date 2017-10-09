//
//  PublisherPageViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/10.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD

class PublisherPageViewController: UIViewController {
    var code = "1001"
    var bannerModel:BannerModel?
    var rows = [1, 1, 10]
    var sectionHeight = [200, 150, 50, 50]
    var titles = ["1","个人简介", "主要经历", "主要成就"]
    var expericences:[ExperienceModel]?
    var achives:[AchiveModel]?
    
    @IBOutlet var doBuy: UIButton!
    @IBOutlet var shareActionTitle: UIBarButtonItem!
    var bannerDetailModel:BannerDetaiStarModel?
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard bannerModel != nil else {
            return
        }
//        shareActionTitle.tintColor = UIColor.init(hexString: AppConst.Color.main)
        doBuy.backgroundColor = UIColor.init(hexString: AppConst.Color.main)
        setCustomTitle(title:"\(bannerModel!.name)（\(bannerModel!.code)）")
        tableView.register(PubInfoHeaderView.self, forHeaderFooterViewReuseIdentifier: "PubInfoHeaderView")
        automaticallyAdjustsScrollViewInsets = false
        requestInfos()
        requestExperience()
        requestAchive()
    }
    func shareAction() {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func shareAction(_ sender: Any) {
        
//        let view : ShareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?.last as! ShareView
//        view.title = "你好网红"
//        view.thumbImage = "QQ"
//        view.descr = "关于你好网红"
//        view.webpageUrl = "http://www.baidu.com"
//        view.shareViewController(viewController: self)
//        UMSocialUIManager.showShareMenuViewInWindow { (platform, userInfo) in
//            let shareObject = UMShareWebpageObject()
//            shareObject.title = self.bannerModel!.name
//            shareObject.descr = self.bannerDetailModel?.introduction
//            let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? BannerDetailImageCell
//            shareObject.thumbImage = cell?.iconImageView.image
//            shareObject.webpageUrl = "www.baidu.com"
//            AppConfigHelper.shared().share(type: platform, shareObject: shareObject, viewControlller: self)
//        }
    }

    @IBAction func buyButtonAction(_ sender: Any) {
        if checkLogin() {
            guard bannerDetailModel != nil else {
                requestInfos()
                return
            }
            let storyBoard = UIStoryboard(name: AppConst.StoryBoardName.Markt.rawValue, bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "MarketDetail") as? MarketDetailViewController
            
            let starListModel = MarketListModel()
            starListModel.name = bannerModel!.name
            starListModel.symbol = bannerModel!.code
            starListModel.pic_tail = bannerDetailModel!.head_url
            starListModel.wid = bannerDetailModel!.weibo_index_id
            vc?.starModel = starListModel
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    func requestInfos() {
        AppAPIHelper.newsApi().requestStarInfo(code: bannerModel!.code, complete: { (response) in
            if let model = response as? BannerDetaiStarModel {
                self.bannerDetailModel = model
                self.tableView.reloadData()
                let string = " \(model.owntimes) 秒"
                self.totalLabel.setAttributeText(text: "总时长\(string)", firstFont: 18, secondFont: 18, firstColor: UIColor(hexString: "999999"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 3, length: string.length()))
            }
        }) { (error) in
            
        }
    }
    func requestExperience() {
        AppAPIHelper.marketAPI().requestStarExperience(code: bannerModel!.code, complete: { (response) in
            if let models =  response as? [ExperienceModel] {
                self.expericences = models
                self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            }
        }) { (error) in
            
        }
    }
    func requestAchive() {
        AppAPIHelper.marketAPI().requestStarArachive(code:  bannerModel!.code, complete: { (response) in
            if let models =  response as? [AchiveModel] {
                self.achives = models
                self.tableView.reloadSections(IndexSet(integer: 3), with: .none)
            }
        }) { (error) in
            
        }
    }
    
}

extension PublisherPageViewController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            
            return expericences?.count ??  0
        } else if section == 3 {
            return achives?.count ?? 0
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sectionHeight[indexPath.section])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "iconImageCell", for: indexPath) as! BannerDetailImageCell
            cell.setImage(imageUrl: bannerDetailModel?.pic_url_tail)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! BannerDetailInfoCell
            
            cell.setData(model: bannerDetailModel)
        
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MarketExperienceCell", for: indexPath) as! MarketExperienceCell
            
            let model = expericences?[indexPath.row]
            cell.setTitle(title: (model?.experience)!)
            return cell
            
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MarketExperienceCell", for: indexPath) as! MarketExperienceCell
            
            let model = achives?[indexPath.row]
            cell.setTitle(title: (model?.achive)!)
            return cell
 
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 40
        }
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PubInfoHeaderView") as? PubInfoHeaderView
            header?.setTitle(title:titles[section])
            return header
        } else {
            return nil
        }
    }
}
