//
//  StarIntroduceViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/7.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import MWPhotoBrowser
import SVProgressHUD
class StarIntroduceViewController: UIViewController {


    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var appointmentButton: UIButton!

    var index = 0
    var starModel:StarSortListModel?
    var sectionHeights = [170, 18, 140]
    var identifers = [StarIntroduceCell.className(), MarketExperienceCell.className(), StarPhotoCell.className()]
    var images:[String] = []
    var starDetailModel:StarDetaiInfoModel?
    var expericences:[ExperienceModel]?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = self.starModel?.name
        tableView.register(PubInfoHeaderView.self, forHeaderFooterViewReuseIdentifier: PubInfoHeaderView.className())
        appointmentButton.layer.shadowColor = UIColor(hexString: "cccccc").cgColor
        appointmentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        appointmentButton.layer.shadowRadius = 1
        tableView.estimatedRowHeight = 20
        appointmentButton.layer.shadowOpacity = 0.5
        requestStarDetailInfo()
        requestExperience()



    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navBarBgAlpha = 0.0
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func requestStarDetailInfo() {
        guard starModel != nil else {
            return
        }
        let requestModel = StarDetaiInfoRequestModel()
        requestModel.star_code = starModel!.symbol
        AppAPIHelper.discoverAPI().requestStarDetailInfo(requestModel: requestModel, complete: { (response) in
            if let model = response as? StarIntroduceResult {
                self.starDetailModel = model.resultvalue
                self.checkImages()
                self.tableView.reloadData()
            }
        }) { (error) in
            
            
        }
    }
    
    func checkImages() {

        if checkUrl(url: starDetailModel?.portray1) {
            images.append(starDetailModel!.portray1)
        }
        if checkUrl(url: starDetailModel?.portray2) {
            images.append(starDetailModel!.portray2)
        }
        if checkUrl(url: starDetailModel?.portray3) {
            images.append(starDetailModel!.portray3)
        }
        if checkUrl(url: starDetailModel?.portray4) {
            images.append(starDetailModel!.portray4)
        }
        
    }
    
    func checkUrl(url:String?)-> Bool {
        if url == nil {return false}
        return url!.hasPrefix("http")
    }
    func requestExperience() {
        guard starModel != nil else {
            return
        }
        AppAPIHelper.marketAPI().requestStarExperience(code: starModel!.symbol, complete: { (response) in
            if let models =  response as? [ExperienceModel] {
                self.expericences = models
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
        }) { (error) in
            
        }
        
    }
    @IBAction func askToBuy(_ sender: Any) {
        
        let storyBoard = UIStoryboard(name: "Heat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "HeatDetailViewController") as! HeatDetailViewController
        vc.starListModel = starModel
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func appointmentAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Market", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "OrderStarViewController") as! OrderStarViewController
        vc.starInfo = starModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func requestPositionCount() {
        guard starModel != nil else {
            return
        }
        
        let r = PositionCountRequestModel()
        r.starcode = starModel!.symbol
        AppAPIHelper.marketAPI().requestPositionCount(requestModel: r, complete: { (response) in
            if let model = response as? PositionCountModel {
                if model.star_time > 0 {
                    let session = NIMSession(self.starDetailModel?.acc_id ?? "", type: .P2P)
                    let vc = YDSSessionViewController(session: session)
                    vc?.starcode = self.starModel?.symbol ?? ""
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else {
                    
                    SVProgressHUD.showErrorMessage(ErrorMessage: "未持有该明星时间", ForDuration: 1.0, completion: nil)
                    
                }
            }
        }) { (error) in
            SVProgressHUD.showErrorMessage(ErrorMessage: "未持有该明星时间", ForDuration: 1.0, completion: nil)
        }
    }

}
extension StarIntroduceViewController:UITableViewDelegate, UITableViewDataSource,MenuViewDelegate, MWPhotoBrowserDelegate, UIScrollViewDelegate, PopVCDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 170 {
            self.navBarBgAlpha = 1.0
        } else {
            self.navBarBgAlpha = 0.0
            
        }
    }
    func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func chat() {

        requestPositionCount()
    }


    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        let photo = MWPhoto(url:URL(string: images[Int(self.index)]))
        return photo
    }

    func menuViewDidSelect(indexPath: IndexPath) {
        index = indexPath.item
        let vc = PhotoBrowserVC(delegate: self)
        present(vc!, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return 0.0001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.001
        case 1:
            return 70
        case 2:
            return 25
        default:
            return 0.01
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if  section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PubInfoHeaderView") as? PubInfoHeaderView
            header?.setTitle(title:"个人介绍")
            header?.contentView.backgroundColor = UIColor(hexString: "fafafa")
            return header
        } else {
            let view = UIView()
            view.backgroundColor = UIColor.init(hexString: "fafafa")
            return view
        }
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return identifers.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return expericences?.count ?? 0
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return UITableViewAutomaticDimension
        }
        return CGFloat(sectionHeights[indexPath.section])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifers[indexPath.section]!, for: indexPath)
        switch indexPath.section {
        case 0:
            if let introCell = cell as? StarIntroduceCell {
                introCell.delegate = self
                guard starDetailModel != nil else {
                    return cell
                }
     
                introCell.setData(model: starDetailModel!)
            }
        case 1:
            if let expericencesCell = cell as? MarketExperienceCell {
                
                let model = expericences![indexPath.row]

                expericencesCell.setTitle(title: model.experience)
            }
        case 2:
            if let photoCell = cell as? StarPhotoCell {
                photoCell.setImageUrls(images: images, delegate:self)
            }
        default:
            break
        }
        return cell
    }
    

}


