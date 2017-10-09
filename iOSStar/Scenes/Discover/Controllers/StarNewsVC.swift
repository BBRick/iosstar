//
//  StarNewsVC.swift
//  YStar
//
//  Created by mu on 2017/7/11.
//  Copyright © 2017年 com.yundian. All rights reserved.
// 慕云飞

import UIKit
import YYText
import SVProgressHUD
import MJRefresh
import Kingfisher
import MWPhotoBrowser

class NewsCell: OEZTableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var newsPic: UIImageView!
    @IBOutlet weak var newsLabel: YYLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var thumbUpBtn: UIButton!
    @IBOutlet weak var CommentBtn: UIButton!
    @IBOutlet weak var showView: UIView!
    
    var newsPicUrl = ""
    
    override func awakeFromNib() {
        nameLabel.textColor = UIColor(hexString: AppConst.Color.main)
        newsPic.isUserInteractionEnabled = true
        showBtn.setImage(UIImage.imageWith(AppConst.iconFontName.showIcon.rawValue, fontSize: CGSize.init(width: 22, height: 17), fontColor: UIColor(hexString: "75C1E7")), for: .normal)
        showBtnTapped(showBtn)
        thumbUpBtn.setImage(UIImage.imageWith(AppConst.iconFontName.thumbIcon.rawValue, fontSize: CGSize.init(width: 16, height: 16), fontColor: UIColor(hexString: AppConst.Color.lightTitle)), for: .normal)
        CommentBtn.setImage(UIImage.imageWith(AppConst.iconFontName.commentIcon.rawValue, fontSize: CGSize.init(width: 16, height: 16), fontColor: UIColor(hexString: AppConst.Color.lightTitle)), for: .normal)
        newsLabel.textParser = YParser.share()
        let showPicGesture = UITapGestureRecognizer.init(target: self, action: #selector(showPicGestureTapped(_:)))
        newsPic.addGestureRecognizer(showPicGesture)
    }
    
    override func update(_ data: Any!) {
        if let model = data as? CircleListModel{
            let userIcon = UIImage.imageWith(AppConst.iconFontName.userPlaceHolder.rawValue, fontSize: iconImage.frame.size, fontColor: UIColor.init(rgbHex: AppConst.ColorKey.main.rawValue))

            iconImage.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader +   model.head_url_tail), placeholder: userIcon)
            nameLabel.text =  model.symbol_name
            newsLabel.text = model.content
            newsPic.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader +   model.pic_url_tail), placeholder: nil)
            newsPicUrl = model.pic_url_tail
            thumbUpBtn.setTitle("点赞(\(model.approve_dec_time)秒)", for: .normal)
            CommentBtn.setTitle("评论(\(model.comment_dec_time)秒)", for: .normal)
            timeLabel.text = Date.marginDateStr(Int(model.create_time))
        }
    }
    
    @IBAction func showBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.25, animations: { [weak self] (animation) in
            self?.showView.isHidden = sender.isSelected
        })
    }
    
    @IBAction func thumbUpOrCommentBtnTapped(_ sender: UIButton) {
        didSelectRowAction(UInt(sender.tag))
        showBtnTapped(showBtn)
    }
    
    func showPicGestureTapped(_ gesture: UITapGestureRecognizer) {
        didSelectRowAction(UInt(103), data: newsPicUrl)
    }
    @IBAction func pushDetail(_ sender: Any) {
        
        didSelectRowAction(UInt(200), data: newsPicUrl)
    }
}

class ThumbupCell: OEZTableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var thumbupNames: UILabel!
    
    override func awakeFromNib() {
        iconImage.image = UIImage.imageWith(AppConst.iconFontName.thumpUpIcon.rawValue, fontSize: iconImage.frame.size, fontColor: UIColor(hexString: AppConst.Color.main))
    }
    
    override func update(_ data: Any!) {
        if let model = data as? CircleListModel{
            contentView.isHidden = model.approve_list.count == 0
            thumbupNames.text = model.approveName
        }
    }
}

class CommentCell: OEZTableViewCell {
    @IBOutlet var commentLabel: YYLabel!
    @IBOutlet weak var commentHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        let replyGesture = UITapGestureRecognizer.init(target: self, action: #selector(replyGestureTapped(_:)))
        commentLabel.addGestureRecognizer(replyGesture)
        commentLabel.isUserInteractionEnabled = true
        commentLabel.textParser = YParser.share()
    }
    
    func update(_ data: Any!, index:IndexPath) {
        if let listModel = data as? CircleListModel{
            let model = listModel.comment_list[index.row-2]
            var comment = "\(model.user_name):\(model.content)"
            if model.direction == 1{
                comment = "\(listModel.symbol_name)回复\(model.user_name):\(model.content)"
            }
            if model.direction == 2{
                comment = "\(model.user_name)回复\(listModel.symbol_name):\(model.content)"
            }
            let contentAttribute = NSMutableAttributedString.init(string: comment)
            contentAttribute.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 0, length: comment.length()))
            if model.direction == 0 {
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: 0, length: model.user_name.length()))
            }
            if model.direction == 1{
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: AppConst.Color.main), range: NSRange.init(location: 0, length: listModel.symbol_name.length()))
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: listModel.symbol_name.length()+2, length: model.user_name.length()))
                
            }
            if model.direction == 2{
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: AppConst.Color.main), range: NSRange.init(location: model.user_name.length()+2, length: listModel.symbol_name.length()))
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: 0, length: model.user_name.length()))
            }
            
            commentLabel.attributedText = contentAttribute
        }
    }
    
    func replyGestureTapped(_ gesture: UITapGestureRecognizer){
        didSelectRowAction(102, data: "")
    }
}

class StarNewsVC: BaseTableViewController, OEZTableViewDelegate, MWPhotoBrowserDelegate {
    
    @IBOutlet var dismissBtn: UIButton!
    @IBOutlet var headerView: UIView!

    var iconImage: UIImageView!
    var starModel:StarSortListModel?
    var tableData: [CircleListModel] = []
    var expericences:[ExperienceModel]?
    var newsPicUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发现网红"
        dismissBtn.setImage(UIImage.imageWith(AppConst.iconFontName.closeIcon.rawValue, fontSize: CGSize.init(width: 22, height: 22), fontColor: UIColor(hexString: AppConst.Color.main)), for: .normal)
        getexperience()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.requestCycleData(0)
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: {
            self.requestCycleData(self.tableData.count)
        })
        if ShareDataModel.share().selectStarCode != ""{
            let share = UIButton.init(type: .custom)
            //        share.setTitle("分享", for: .normal)
            iconImage = UIImageView.init()
            share.setImage(UIImage.init(named: "star_share"), for: .normal)
            share.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
            share.addTarget(self, action: #selector(sharetothird), for: .touchUpInside)
            let item = UIBarButtonItem.init(customView: share)
            item.tintColor = UIColor(hexString: AppConst.Color.main)
//            self.navigationItem.rightBarButtonItem = item

            self.navigationItem.rightBarButtonItem = item
            if starModel?.pic_tail != nil{
            iconImage.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader +   (starModel?.pic_tail)!), placeholder: nil)
            }
        }
        requestCycleData(0)
    }
    func sharetothird(){
        
//        if let model = expericences?[0]{
//            let view : ShareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?.last as! ShareView
//            view.title = (starModel?.name)! + "(正在你好网红 出售TA的时间)"
//            view.Image = iconImage.image
//            view.descr = model.experience
//            view.webpageUrl = String.init(format: "%@?uid=%d&star_code=%@", AppConst.shareUrl,StarUserModel.getCurrentUser()?.userinfo?.id ?? 0,ShareDataModel.share().selectStarCode)
//            
//            view.shareViewController(viewController: self)
//            
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    enum cellAction: Int {
        case thumbUp = 100
        case comment = 101
        case reply = 102
        case showPic = 103
        case pushDetail = 200
    }
    
    func endRefresh() {
        if tableView.mj_header.state == .refreshing {
            tableView.mj_header.endRefreshing()
        }
        if tableView.mj_footer.state == .refreshing {
            tableView.mj_footer.endRefreshing()
        }
    }
    
    func requestCycleData(_ position: Int) {
        let param = CircleListRequestModel()
        param.pos = Int64(position)
        param.star_code = ShareDataModel.share().selectStarCode
        AppAPIHelper.circleAPI().requestStarCircleList(requestModel: param, complete: { [weak self](result) in
            if let data = result as? [CircleListModel]{
                for model in data{
                    model.caclulateHeight()
                }
                if position == 0{
                    self?.tableData = data
                }else{
                    self?.tableData += data
                }
                self?.tableView.reloadData()
            }
            self?.endRefresh()
        }, error: errorBlockFunc())
    }
    
   
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
     func getexperience(){
        AppAPIHelper.marketAPI().requestStarExperience(code: ShareDataModel.share().selectStarCode, complete: { (response) in
            if let models =  response as? [ExperienceModel] {
                self.expericences = models
              
            }
        }) { (error) in
            
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = tableData[section]
        return model.comment_list.count + 2
    }
    
    func showWarning() {
        let alertVC = UIAlertController.init(title: "付费确认", message: "点赞/评论/回复将会消耗您一秒的时间", preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "确认", style: .default, handler: nil)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func dismissBtnTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] (animation) in
            self?.tableView.y -= 64
            self?.tableView.height += 64
            self?.headerView.isHidden = true
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = tableData[indexPath.section]
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.className()) as? NewsCell
          
            cell?.update(model)
            return cell!
        }
        
        if indexPath.row == 1{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ThumbupCell.className()) as? ThumbupCell
            cell?.update(model)
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.className()) as? CommentCell
        cell?.update(model, index:indexPath)
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, cellIdentifierForRowAtIndexPath indexPath: IndexPath) -> String? {
        switch indexPath.row {
        case 0:
            return NewsCell.className()
        case 1:
            return ThumbupCell.className()
        default:
            return CommentCell.className()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = tableData[indexPath.section]
        
        if indexPath.row == 0{
            return model.headerHeight
        }
        
        if indexPath.row == 1{
            return model.thumbUpHeight
        }
        
        
        if let commentModel = model.comment_list[indexPath.row - 2] as? CircleCommentModel{
            return commentModel.circleHeight
        }
        
        return 0
        
    }
    
    override func isSections() -> Bool {
        return true
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func tableView(_ tableView: UITableView!, rowAt indexPath: IndexPath!, didAction action: Int, data: Any!) {
        let model = tableData[indexPath.section]
        switch action {
        case cellAction.thumbUp.rawValue:
            for approve in model.approve_list{
                if approve.uid == (StarUserModel.getCurrentUser()?.userinfo?.id)!{
                    SVProgressHUD.showWainningMessage(WainningMessage: "您已经点赞过了", ForDuration: 2, completion: nil)
                    return
                }
            }
            
            let param = ApproveCircleModel()
            param.star_code = model.symbol
            param.circle_id = model.circle_id
            AppAPIHelper.circleAPI().approveCircle(requestModel: param, complete: { (response) in
                if let result = response as? ResultModel{
                    if result.result == 1{
                        SVProgressHUD.showSuccessMessage(SuccessMessage: "点赞成功", ForDuration: 2, completion: { 
                            let user = ApproveModel()
                            user.uid = (StarUserModel.getCurrentUser()?.userinfo?.id)!
                            user.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                            model.approve_list.append(user)
                            model.caclulateHeight()
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        })
                    }
                }
            }, error: errorBlockFunc())
            break
        case cellAction.comment.rawValue:
            let keyboardVC = KeyboardInputViewController()
            keyboardVC.modalPresentationStyle = .custom
            keyboardVC.modalTransitionStyle = .crossDissolve
            keyboardVC.sendMessage = { [weak self] (message) in
                let param = CommentCircleModel()
                param.content = message as! String
                param.star_code = model.symbol
                param.circle_id = model.circle_id
                AppAPIHelper.circleAPI().commentCircle(requestModel: param, complete: { (response) in
                    if let result = response as? ResultModel{
                        if result.result == 1{
                            SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 2, completion: {
                                let comment = CircleCommentModel()
                                comment.uid = Int((StarUserModel.getCurrentUser()?.userinfo?.id)!)
                                comment.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                                comment.direction = 0
                                comment.priority = 0
                                comment.content = message as! String
                                comment.calculateHeight()
                                model.comment_list.append(comment)
//                                tableView.reloadRows(at: [indexPath], with: .automatic)
                                tableView.reloadData()
                            })
                        }
                    }
                }, error: self?.errorBlockFunc())
            }
            present(keyboardVC, animated: true, completion: nil)
        case cellAction.reply.rawValue:
            let commentModel = model.comment_list[indexPath.row-2]
            if commentModel.direction != 1{
                return
            }
            let keyboardVC = KeyboardInputViewController()
            keyboardVC.modalPresentationStyle = .custom
            keyboardVC.modalTransitionStyle = .crossDissolve
            keyboardVC.sendMessage = { [weak self](message) in
                let param = CommentCircleModel()
                param.content = message as! String
                param.star_code = model.symbol
                param.circle_id = model.circle_id
                param.direction = 2
                AppAPIHelper.circleAPI().commentCircle(requestModel: param, complete: { (response) in
                    if let result = response as? ResultModel{
                        if result.result == 1{
                            SVProgressHUD.showSuccessMessage(SuccessMessage: "回复成功", ForDuration: 2, completion: {
                                let comment = CircleCommentModel()
                                comment.uid = Int((StarUserModel.getCurrentUser()?.userinfo?.id)!)
                                comment.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                                comment.direction = 2
                                comment.priority = 0
                                comment.content = message as! String
                                model.comment_list.append(comment)
                                tableView.reloadData()
                            })
                        }
                    }
            
                }, error: self?.errorBlockFunc())
            }
            present(keyboardVC, animated: true, completion: nil)
        case cellAction.showPic.rawValue:
            if let url = data as? String{
                newsPicUrl = url
                let vc = PhotoBrowserVC(delegate: self)
                present(vc!, animated: true, completion: nil)
            }
        case cellAction.pushDetail.rawValue:
            StartModel.getStartName(startCode: model.symbol) { (response) in
                let star = response as? StartModel
                let starListModel = StarSortListModel()
                
                starListModel.symbol = model.symbol
                starListModel.name = model.symbol_name
                starListModel.pic_tail  = (star?.pic_url_tail)!
                let introVC =  UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "StarIntroduceViewController") as! StarIntroduceViewController
                introVC.starModel = starListModel
                
                self.navigationController?.pushViewController(introVC, animated: true)
            }
            break
            
        default: break
            // print("")
        }
        
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {

        let photo = MWPhoto(url:URL(string:ShareDataModel.share().qiniuHeader + newsPicUrl))
    
        return photo
    }
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, actionButtonPressedForPhotoAt index: UInt) {
        photoBrowser.dismissController()
    }
}
