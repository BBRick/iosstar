//
//  VoiceQuestionVC.swift
//  iOSStar
//
//  Created by mu on 2017/8/16.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class VoiceQuestionCell: OEZTableViewCell{
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var voiceImg: UIImageView!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var voiceIcon: UIImageView!
    @IBOutlet weak var voiceCountLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        self.selectionStyle = .none
        
        iconImage.image = UIImage.imageWith("\u{e655}", fontSize: CGSize.init(width: 26, height: 26), fontColor: UIColor.init(rgbHex: AppConst.ColorKey.main.rawValue))
    }
    
    override func update(_ data: Any!) {
        if let response  = data as? UserAskDetailList{
            contentLabel.text = response.uask
            iconImage.kf.setImage(with: URL(string : response.headUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            nameLabel.text = response.nickName
            timeLabel.text = Date.yt_convertDateStrWithTimestempWithSecond(Int(response.answer_t), format: "YYYY-MM-dd")
            
            if response.purchased == 1{
                let attr = NSMutableAttributedString.init(string: "点击播放")
                title.attributedText = attr
            }
            else  if response.purchased == 0{
                let attr = NSMutableAttributedString.init(string: "花费\((response.c_type + 1) * 15)秒偷听")
                attr.addAttributes([NSForegroundColorAttributeName: UIColor.init(rgbHex: 0xfb9938)], range: NSRange.init(location: 2, length: "\((response.c_type + 1) * 15)".length()))
                title.attributedText = attr
                
            }
            
            voiceBtn.addTarget(self, action: #selector(dopeep), for: .touchUpInside)
            voiceCountLabel.text = "\(response.s_total)人听过"
        }
    }
    
    @IBAction func dopeep(_ sender: Any) {
        didSelectRowAction(3, data: nil)
    }
}

class VoiceQuestionVC: BasePageListTableViewController ,OEZTableViewDelegate {
    
    var starModel: StarSortListModel = StarSortListModel()
    var voiceimg: UIImageView!
    var height = UIScreen.main.bounds.size.height - 64
    override func viewDidLoad() {
        super.viewDidLoad()
        title = starModel.name
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        initNav()
    }
    
    func initNav() {
        let rightItem = UIBarButtonItem.init(title: "历史定制", style: .plain, target: self, action: #selector(rightItemTapped(_:)))
        
        
        //        title  =   "语音定制"
        navigationItem.rightBarButtonItem = rightItem
        navigationItem.rightBarButtonItem?.tintColor = UIColor.init(hexString: AppConst.Color.titleColor)
    }
    func tableView(_ tableView: UITableView!, rowAt indexPath: IndexPath!, didSelectColumnAt column: Int){
    }
    
    func tableView(_ tableView: UITableView!, rowAt indexPath: IndexPath!, didAction action: Int, data: Any!){
        if let arr = self.dataSource?[0] as? Array<AnyObject>{
            if PLPlayerHelper.shared().player.isPlaying{
                PLPlayerHelper.shared().player.stop()
            }
            if voiceimg != nil{
                self.voiceimg.image = UIImage.init(named: String.init(format: "listion"))
            }
            if let cell = tableView.cellForRow(at: indexPath) as? VoiceQuestionCell{
                voiceimg = cell.voiceImg
            }
            
            if let model = arr[indexPath.row] as? UserAskDetailList{
                if model.purchased == 1{
                    doplay(model)
                }else{
                    let request = PeepVideoOrvoice()
                    request.qid = Int(model.id)
                    request.starcode = starModel.symbol
                    request.cType = model.c_type
                    AppAPIHelper.discoverAPI().peepAnswer(requestModel: request, complete: { (result) in
                        if let response = result as? ResultModel{
                            if response.result == 0{
                                model.purchased = 1
                                tableView.reloadRows(at: [indexPath], with: .none)
                                 self.doplay(model)
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
    }
    
    func rightItemTapped(_ sender: Any) {
        if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: VoiceHistoryVC.className()) as? VoiceHistoryVC{
            vc.starModel = starModel
            _ = self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didRequest(_ pageIndex: Int) {
        
        let model = StarAskRequestModel()
        model.pos = (pageIndex - 1) * 10
        model.starcode = starModel.symbol
        model.aType = 2
        model.pType = 1
        AppAPIHelper.discoverAPI().staraskQuestion(requestModel: model, complete: { [weak self](result) in
            if let response = result as? UserAskList {
                self?.didRequestComplete([response.circle_list] as AnyObject )
                if (self?.dataSource != nil){
                    self?.height = 64
                }
                self?.tableView.reloadData()
            }
            
        }) { (error) in
            self.didRequestComplete(nil)
            if (self.dataSource != nil){
                self.height = 64
            }
        }
        
    }
    override func isSections() -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellIdentifierForRowAtIndexPath indexPath: IndexPath) -> String? {
        return VoiceQuestionCell.className()
    }
    
}
extension VoiceQuestionVC{
    
    func doplay(_ model : UserAskDetailList){
        let url = URL(string: ShareDataModel.share().qiniuHeader +  model.sanswer)
        PLPlayerHelper.shared().player.play(with: url)
        PLPlayerHelper.shared().play(isRecord: false)
        PLPlayerHelper.shared().player.play()
        PLPlayerHelper.shared().resultBlock =  {  [weak self] (result) in
            if let status = result as? PLPlayerStatus{
                if status == .statusStopped{
                    PLPlayerHelper.shared().doChanggeStatus(4)
                    self?.voiceimg.image = UIImage.init(named: String.init(format: "listion"))
                }
                if status == .statusPaused{
                    PLPlayerHelper.shared().doChanggeStatus(4)
                    self?.voiceimg.image = UIImage.init(named: String.init(format: "listion"))
                }
                if status == .statusPreparing{
                    PLPlayerHelper.shared().doChanggeStatus(0)
                    PLPlayerHelper.shared().resultCountDown = {[weak self] (result) in
                        if let response = result as? Int{
                            self?.voiceimg.image = UIImage.init(named: String.init(format: "voice_%d",response))
                        }
                    }
                }
                if status == .statusError{
                    PLPlayerHelper.shared().doChanggeStatus(4)
                    self?.voiceimg.image = UIImage.init(named: String.init(format: "listion"))
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        //        PLPlayerHelper.shared().avplayNewUrl(urlStr)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView.init(frame: CGRect.init(x: 0, y: Int(height - 64), width: Int(kScreenWidth), height: 64))
        //        footer.backgroundColor = UIColor.init(rgbHex: 0xfafafa)
        footer.backgroundColor = UIColor.clear
        let footerBtn = UIButton.init(type: .custom)
        footerBtn.frame = CGRect.init(x: 24, y: Int(height - 50), width: Int(kScreenWidth-48), height: 44)
        footerBtn.layer.cornerRadius = 3
        footerBtn.backgroundColor = UIColor.init(rgbHex: 0xfb9938)
        footerBtn.setTitle("找TA定制", for: .normal)
        footerBtn.addTarget(self, action: #selector(footerBtnTapped(_:)), for: .touchUpInside)
        footer.addSubview(footerBtn)
        return footer
    }
    
    func footerBtnTapped(_ sender: UIButton) {
        if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: VoiceAskVC.className()) as? VoiceAskVC{
            vc.starModel = starModel
            _ = navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
