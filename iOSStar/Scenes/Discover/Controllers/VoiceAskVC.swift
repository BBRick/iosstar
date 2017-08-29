//
//  VoiceAskVC.swift
//  iOSStar
//
//  Created by mu on 2017/8/17.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class VoiceAskVC: BaseTableViewController {
    
    @IBOutlet var contentText: UITextView!
    @IBOutlet weak var placeholdLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var voice15Btn: UIButton!
    @IBOutlet weak var voice30Btn: UIButton!
    @IBOutlet weak var voice60Btn: UIButton!
    @IBOutlet var switchopen: UISwitch!
    var starModel: StarSortListModel = StarSortListModel()
    private var lastVoiceBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "向TA定制"
        voiceBtnTapped(voice15Btn)
        navright()
    }

    @IBAction func voiceBtnTapped(_ sender: UIButton) {
        lastVoiceBtn?.isSelected = false
        sender.isSelected = !sender.isSelected
        lastVoiceBtn = sender
    }
    func navright(){
        let share = UIButton.init(type: .custom)
        share.frame = CGRect.init(x: 0, y: 0, width: 70, height: 30)
        share.setTitle("发布", for: .normal)
        share.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        share.setTitleColor(UIColor.init(hexString: AppConst.Color.main), for: .normal)
        share.addTarget(self, action: #selector(publish), for: .touchUpInside)
        let item = UIBarButtonItem.init(customView: share)
        self.navigationItem.rightBarButtonItem = item
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: NSNotification.Name.UITextViewTextDidChange, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: NSNotification.Name.UITextViewTextDidChange, object: nil);
    }
    func publish(){
//        if self.preview ==  ""{
//            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入视频内容", ForDuration: 2, completion: nil)
//        }
        let request = AskRequestModel()
        request.pType = switchopen.isOn ? 0 : 1
        request.aType = 2
        request.starcode = starModel.symbol
        request.uask = contentText.text
        request.videoUrl = ""
        request.cType = voice15Btn.isSelected ? 15 : (voice30Btn.isSelected ? 30 : (voice60Btn.isSelected ? 60 : 15))
        AppAPIHelper.discoverAPI().videoAskQuestion(requestModel:request, complete: { (result) in
            if let model = result as? ResultModel{
                if model.result == 0{
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "语音问答成功", ForDuration: 1, completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                if model.result == 1{
                    SVProgressHUD.showErrorMessage(ErrorMessage: "问答失败", ForDuration: 2, completion: nil)
                }
            }
        }) { (error) in
            self.didRequestError(error)
        }
        
        
    }
    // 限制不超过200字
    func textViewNotifitionAction(userInfo:NSNotification){
        let textVStr = contentText.text as NSString;
        
        if (textVStr.length > 100) {
            contentText.resignFirstResponder()
            return
        }else{
            countLabel.text = "\(textVStr.length)/100"
        }
        
    }
    func textViewDidChange(_ textView: UITextView) {
        contentText.text = textView.text
        if textView.text == "" {
            placeholdLabel.text = "输入你的问题，可选择公开或者私密，公开提问能呗其他用户所见 "
            placeholdLabel.isHidden = false
        } else {
            placeholdLabel.text = ""
            placeholdLabel.isHidden = true
        }
    }
}
