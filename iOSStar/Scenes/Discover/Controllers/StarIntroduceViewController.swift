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
    var showMoreIntroduce  = true
    var index = 0
    var headerImg = UIImageView()
    var starModel:StarSortListModel?
    var sectionHeights = [170,18 , 120 , 150]
//    var sectionHeights = [170,18 , 120, 120,124 , 150]
  //  var identifers = [StarIntroduceCell.className(),MarketExperienceCell.className(), StarCirCleCell.className(), StarDynamicCell.className(),StarDetailCirCell.className() ,StarPhotoCell.className()]
    var identifers = [StarIntroduceCell.className(),MarketExperienceCell.className(),StarPhotoCell.className()]
    var images:[String] = []
    var starDetailModel:StarDetaiInfoModel?
    var expericences:[ExperienceModel]?
    var StarDetail:StarDetailCircle?
    var realName = false
    var showCirCle = false
    var showCirCleUrl = ""
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarBgAlpha = 0.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        tableView.register(PubInfoHeaderView.self, forHeaderFooterViewReuseIdentifier: PubInfoHeaderView.className())
        appointmentButton.backgroundColor = UIColor(hexString: AppConst.Color.lightAction)
        buyButton.backgroundColor = UIColor(hexString: AppConst.Color.darkAction)
        requestStarDetailInfo()
        requestExperience()
        requeseDetail()
    }
    
    func requeseDetail(){
        let model = CirCleStarDetail()
        model.starcode = (self.starModel?.symbol)!
        model.aType = 1
        model.pType = 1
        AppAPIHelper.discoverAPI().requestStarDetail(requestModel: model, complete: { (result) in
            if let response = result as? StarDetailCircle{
                self.StarDetail = response
                self.tableView.reloadData()
            }
        }) { (error ) in
            
        }
    }
    
    func sharetothird(){
        if let model = expericences?[0]{
//            let share  = Share()
//            let vc = UIStoryboard.init(name: "Market", bundle: nil).instantiateViewController(withIdentifier: "ShareVC") as? ShareVC
//            vc?.modalPresentationStyle = .custom
//            share.titlestr = (starDetailModel?.star_name)! + "(正在你好网红 出售TA的时间)"
//            share.Image = headerImg.image
//            share.descr = model.experience
//            share.work = (starDetailModel?.work)!
//            share.star_code = (starDetailModel?.star_code)!
//            share.name = (starDetailModel?.star_name)!
//            vc?.share = share
//            share.webpageUrl = String.init(format: "%@?uid=%d&star_code=%@", AppConst.shareUrl,StarUserModel.getCurrentUser()?.userinfo?.id ?? 0,(self.starDetailModel?.star_code)!)
//            
//            vc?.modalTransitionStyle = .crossDissolve
//            present(vc!, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.getUserRealmInfo { [weak self](result) in
            if let model = result{
                if let object =  model as? [String : AnyObject]{
                    if object["realname"] as! String == ""{
                        self?.realName = true
                    }else{
                        self?.realName = false
                    }
                }
            }
        }
        if let _ = UserDefaults.standard.value(forKey: AppConst.guideKey.StarIntroduce.rawValue) as? String {
            
        }else{
            showGuideVC(.StarIntroduce, handle: { (vc)in
                if let guideVC = vc as? GuideVC{
                    if guideVC.guideType == AppConst.guideKey.StarIntroduce{
                        guideVC.dismiss(animated: true, completion:nil)
                        UserDefaults.standard.set("ok", forKey: AppConst.guideKey.StarIntroduce.rawValue)
                    }
                }
            })
        }
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
        },error: nil)
    }
    
    func requestExperience() {
        guard starModel != nil else {
            return
        }
        AppAPIHelper.marketAPI().requestStarExperience(code: starModel!.symbol, complete: { (response) in
            if let models =  response as? [ExperienceModel] {
                self.expericences = models
                self.tableView.reloadData()
            }
        },error:nil)
    }
    
    func checkImages() {
        if checkUrl(url: starDetailModel?.portray1_tail) {
            images.append(ShareDataModel.share().qiniuHeader + starDetailModel!.portray1_tail)
        }
        if checkUrl(url: starDetailModel?.portray2_tail) {
            images.append(ShareDataModel.share().qiniuHeader + starDetailModel!.portray2_tail)
        }
        if checkUrl(url: starDetailModel?.portray3_tail) {
            images.append(ShareDataModel.share().qiniuHeader + starDetailModel!.portray3_tail)
        }
        if checkUrl(url: starDetailModel?.portray4_tail) {
            images.append(ShareDataModel.share().qiniuHeader + starDetailModel!.portray4_tail)
        }
        self.tableView.reloadData()
    }
    
    func checkUrl(url:String?)-> Bool {
        if url == nil {return false}
        return url!.length()>0 ? true : false
    }
    
    @IBAction func askToBuy(_ sender: Any) {
        
        if self.starDetailModel?.publish_type !=  2 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "当前该网红非流通阶段，请等待为流通阶段", ForDuration: 2, completion: nil)
            return
        }
        let storyBoard = UIStoryboard(name: "Heat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "HeatDetailViewController") as! HeatDetailViewController
        vc.starListModel = starModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func appointmentAction(_ sender: Any) {
        if starDetailModel == nil{
            return
        }
        
        if self.starDetailModel?.publish_type !=  2 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "当前该网红非流通阶段，请等待为流通阶段", ForDuration: 2, completion: nil)
            return
        }
        
        let storyBoard = UIStoryboard(name: "Market", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "OrderStarViewController") as! OrderStarViewController
        starModel?.home_pic_tail = (starDetailModel?.back_pic_tail)!
        vc.starInfo = starModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func requestPositionCount() {
        guard starModel != nil else {
            return
        }
        if self.starDetailModel?.publish_type == 0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "当前该网红非流通阶段，请等待为流通阶段", ForDuration: 2, completion: nil)
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
                    
                    vc?.starname = (self.starDetailModel?.star_name)!
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else {
                    
                    SVProgressHUD.showErrorMessage(ErrorMessage: "未持有该网红时间", ForDuration: 1.0, completion: nil)
                    
                }
            }
        }) { (error) in
            SVProgressHUD.showErrorMessage(ErrorMessage: "未持有该网红时间", ForDuration: 1.0, completion: nil)
        }
    }
    
}
//StarDetailCirCellDelegate

extension StarIntroduceViewController:UITableViewDelegate, UITableViewDataSource,MenuViewDelegate, MWPhotoBrowserDelegate, UIScrollViewDelegate, PopVCDelegate,MarketExperienceCellDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 170 {
            self.navBarBgAlpha = 1.0
            title = self.starModel?.name
        } else {
            self.navBarBgAlpha = 0.0
            title =   ""
            
        }
    }
    func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func chat() {
        if realName{
            showRealname()
            return
        }
        requestPositionCount()
    }
    
    func share() {
        sharetothird()
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        var urlString = images[Int(index)]
        if  !urlString.hasPrefix("http") {
            urlString = ShareDataModel.share().qiniuHeader + urlString
        }
        let photo = MWPhoto(url:URL(string: images[Int(self.index)]))
        return photo
    }
    
    func menuViewDidSelect(indexPath: IndexPath) {
        index = indexPath.item
        showCirCle = false
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
            return 0.001
        case 3:
            return 70
        case 4:
            return 0.01
        case 5:
            return 70
        default:
            return 0.01
        }
        
    }
    func showMore() {
        showMoreIntroduce = false
        self.tableView.reloadSections(IndexSet.init(integer: 1), with: .fade)
    }
    func Packup() {
        showMoreIntroduce = true
        self.tableView.reloadSections(IndexSet.init(integer: 1), with: .fade)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if  section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PubInfoHeaderView") as? PubInfoHeaderView
            header?.setTitle(title:"个人介绍")
            header?.contentView.backgroundColor = UIColor(hexString: "fafafa")
            return header
            
            
        }
        else  if  section == 5 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PubInfoHeaderView") as? PubInfoHeaderView
            header?.setTitle(title:"个人写真")
            header?.contentView.backgroundColor = UIColor(hexString: "fafafa")
            return header
        }
        else  if  section == 3 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PubInfoHeaderView") as? PubInfoHeaderView
            header?.setTitle(title:"最新动态")
            header?.contentView.backgroundColor = UIColor(hexString: "fafafa")
            return header
        }
        else  if  section == 2{
            let view = UIView()
            view.backgroundColor = UIColor.init(hexString: "fafafa")
            return view
        }
            
        else {
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
                headerImg = introCell.iconImageView
            }
        case 1:
            if let expericencesCell = cell as? MarketExperienceCell {
                
                expericencesCell.delegate = self
                expericencesCell.show.isHidden = true
                if showMoreIntroduce{
                    expericencesCell.show.isHidden = true
                    expericencesCell.showHeight.constant = 15
                    
                }else{
                    //最后一区
                    expericencesCell.show.isHidden = true
                    if indexPath.row == (expericences?.count)! - 1{
                        expericencesCell.show.isHidden = true
                // expericencesCell.show.setTitle("点击收起", for: .normal)
                        expericencesCell.showHeight.constant = 15
                    }else{
                        expericencesCell.show.isHidden = true
                        expericencesCell.showHeight.constant = 0
                    }
                    
                    
                }
                if expericences != nil {
                    let model = expericences![indexPath.row]
                    
                    expericencesCell.setTitle(title: model.experience)
                }
                
            }
        case 5:
            if let StarCirCle = cell as? StarCirCleCell {
                StarCirCle.delegate = self
                StarCirCle.backgroundColor = UIColor.clear
                //                photoCell.setImageUrls(images: images, delegate:self)
            }
            
        case 3:
            if let photoCell = cell as? StarDynamicCell {
                
                photoCell.datasource = self.StarDetail
                //                photoCell.setImageUrls(images: images, delegate:self)
                photoCell.delegate = self
        }//StarDetailCirCell
        case 4:
            if let photoCell = cell as? StarDetailCirCell {
                //                photoCell.setImageUrls(images: images, delegate:self)
                photoCell.datasource = self.StarDetail
                 photoCell.delegate = self
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
    func starask(){
        
        if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: VideoManagerVC.className()) as? VideoManagerVC{
            vc.starModel = starModel!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func voice(){
        
        if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "VoiceManagerVC") as? VoiceManagerVC{
            vc.starModel = starModel!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func staractive(){
        
        //TakeMovieVC
        ShareDataModel.share().selectStarCode = (starModel?.symbol)!
        if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: StarNewsVC.className()) as? StarNewsVC{
            //TakeMovieVC
            vc.starModel = starModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
extension StarIntroduceViewController : StarCirCleCellDelegate,StarDynamicCellDelegate,StarDetailCirCellDelegate{
    
    func starask(_select: UserAskDetailList) {
        if let model  = _select as? UserAskDetailList{
            if model.purchased == 1{
                if model.video_url != ""{
                    self.pushcontroller(pushSreing: PlayVideoVC.className(), model: model, playString: model.video_url)
                }
                else{
                    self.pushcontroller(pushSreing: PlaySingleVC.className(), model: model, playString: model.sanswer)
                }
            }
            else{
                let request = PeepVideoOrvoice()
                request.qid = Int(model.id)
                request.starcode = (starModel?.symbol)!
                request.cType = model.c_type
                request.askUid = model.uid
                AppAPIHelper.discoverAPI().peepAnswer(requestModel: request, complete: { (result) in
                    if let response = result as? ResultModel{
                        if response.result == 0{
                            model.purchased = 1
                            
                            if model.video_url != ""{
                                self.pushcontroller(pushSreing: PlayVideoVC.className(), model: model, playString: model.video_url)
                            }
                            else{
                                self.pushcontroller(pushSreing: PlaySingleVC.className(), model: model, playString: model.sanswer)
                            }
                        }else{
                            SVProgressHUD.showWainningMessage(WainningMessage: "您持有的时间不足", ForDuration: 1, completion: nil)
                        }
                    }
                }, error: { (error) in
                    self.didRequestError(error)
                })
                
            }
        }
    }
    
    func showBigImg(_select: CircleListModel) {
        showCirCle = true
        showCirCleUrl = String(ShareDataModel.share().qiniuHeader + _select.pic_url_tail)
        let vc = PhotoBrowserVC(delegate: self)
        present(vc!, animated: true, completion: nil)
    }
    
}


