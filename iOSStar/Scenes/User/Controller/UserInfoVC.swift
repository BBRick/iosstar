//
//  UserInfoVC.swift
//  iOSStar
//
//  Created by sum on 2017/5/9.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD

class UserInfoVC: UITableViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    // 手机号
    @IBOutlet weak var phone: UILabel!
    // 昵称
    @IBOutlet var nickName: UITextField!
    // 头像
    @IBOutlet var headerImg: UIImageView!
    // 身份证号
    @IBOutlet weak var realCard: UILabel!
    // 真实姓名
    @IBOutlet weak var realname: UILabel!
    
    
    var userInfoData : UserInfoModel?
    
    var uploadAlertController:UIAlertController!
    var imagePickerController:UIImagePickerController!
    override func viewDidLoad() {
       
        super.viewDidLoad()
        let view = UIView.init()
        view.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = view

        title = "个人信息"
        initAlertController()
        initImagePickerController()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .done, target: self, action: #selector(rightItmeClick))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: AppConst.Color.main)

        
        self.getUserRealmInfo { (result) in
            if let model = result{

                let object =  model as! [String : String]
                 if object["realname"] != "" {
                self.realname.text = object["realname"]
                let  card = object["id_card"]
                let index = card?.index((card?.startIndex)!, offsetBy: 3)
                let index1 = card?.index((card?.endIndex)!, offsetBy: -4)
                self.realCard.text = (card?.substring(to: index!))! + "****" + (card?.substring(from: index1!))!
                 }else{
                    self.realname.text = "未实名认证"
                    self.realCard.text = "未实名认证"
                }
            }
        
        }

        let  phonetext  = (UserDefaults.standard.object(forKey: "phone") as! String)
      
        let index = phonetext.index(phonetext.startIndex, offsetBy: 3)
        let index1 = phonetext.index(phonetext.endIndex, offsetBy: -4)
        self.phone.text =  (phonetext.substring(to: index)) + "****" + (phonetext.substring(from: index1))
        
        if userInfoData?.nick_name == "" {
            let nameUid = StarUserModel.getCurrentUser()?.userinfo?.id
            let stringUid = String.init(format: "%d", nameUid!)
            nickName.text = "星悦用户" + stringUid
        } else {
            nickName.text = userInfoData?.nick_name
        }
        
    
       var headUrl = ""
        if userInfoData != nil {
            headUrl = userInfoData!.head_url
        }
       headerImg.kf.setImage(with: URL(string: headUrl), placeholder: UIImage(named:"avatar_team"), options: nil, progressBlock: nil, completionHandler: nil)
//        self.nickName.text = (phonetext.substring(to: index)) + "****" + (phonetext.substring(from: index1))
        // self.nickName.text = phonetext
    }
    
    // 保存名称
    func rightItmeClick() {
        // 修改昵称
        if nickName.text?.length() == 0 || (nickName.text?.length())! >= 15 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "昵称不合法", ForDuration: 2.0, completion: nil)
            return
        }
        let requestModel = ModifyNicknameModel()
        requestModel.nickname = nickName.text!

        AppAPIHelper.user().modfyNickname(requestModel: requestModel, complete: { (result) in
            // result = 1 成功  result = 0 失败
            if let responseData = result {
                if responseData["result"] as! Int == 1 {
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "保存成功!", ForDuration: 2.0, completion: { 
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    SVProgressHUD.showSuccessMessage(SuccessMessage: "修改失败,请稍后再试!", ForDuration: 2.0, completion:nil)
                }
            }
        }) { (error) in
            
            print(error)
            self.didRequestError(error)
//            SVProgressHUD.showErrorMessage(ErrorMessage: error.userInfo["NSLocalizedDescription"] as! String, ForDuration: 2.0, completion: nil)
        }
    }
    
    
    
    

   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
//                   present(self.uploadAlertController, animated:true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: initAlertController
    func initAlertController()
    {
        weak var blockSelf = self
        self.uploadAlertController = UIAlertController(title:nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        self.uploadAlertController.view.tintColor = UIColor.white
        let takePhoto = UIAlertAction(title:"拍照", style:UIAlertActionStyle.default) { (action:UIAlertAction)in
            blockSelf?.actionAction(action: action)
        }
        let photoLib = UIAlertAction(title:"从相册选择", style:UIAlertActionStyle.default) { (action:UIAlertAction)in
            blockSelf?.actionAction(action: action)
        }
        photoLib.setValue(UIColor.blue, forKey: "titleTextColor")
        photoLib.setValue(UIColor.blue, forKey: "titleTextColor")
        photoLib.setValue(UIColor.blue, forKey: "titleTextColor")
        let cancel = UIAlertAction(title:"取消", style:UIAlertActionStyle.cancel) { (action:UIAlertAction)in
            blockSelf?.actionAction(action: action)
        }
        cancel.setValue(UIColor.init(hexString: AppConst.Color.main), forKey: "titleTextColor")
        takePhoto.setValue(UIColor.init(hexString: AppConst.Color.main), forKey: "titleTextColor")
        photoLib.setValue(UIColor.init(hexString: AppConst.Color.main), forKey: "titleTextColor")
        self.uploadAlertController?.addAction(takePhoto)
        self.uploadAlertController?.addAction(photoLib)
        self.uploadAlertController?.addAction(cancel)
    }
    func initImagePickerController()
    {
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        // 设置是否可以管理已经存在的图片或者视频
        self.imagePickerController.allowsEditing = true
    }
    func actionAction(action:UIAlertAction)
    {
        if action.title == "拍照" {
            self.getImageFromPhotoLib(type: .camera)
        }else if action.title == "从相册选择" || action.title == "更换头像" {
            self.getImageFromPhotoLib(type: .photoLibrary)
        }else if action.title == "删除照片" {
//            self.headImg.image =UIImage(named:"head")
        }
    }
    func getImageFromPhotoLib(type:UIImagePickerControllerSourceType)
    {
        self.imagePickerController.sourceType = type
        //判断是否支持相册
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.navigationController?.present(self.imagePickerController, animated: true, completion:nil)
        }
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String :Any]){
        
        let type:String = (info[UIImagePickerControllerMediaType]as!String)
        //当选择的类型是图片
        if type=="public.image"
        {

            let img = info[UIImagePickerControllerOriginalImage]as?UIImage
            self.headerImg.image = img
            picker.dismiss(animated:true, completion:nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:nil)
    }


}

