//
//  ContainVC.swift
//  iOSStar
//
//  Created by sum on 2017/5/5.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
//设置枚举选择事件
enum doStateClick{
    case doRegist    //  注册
    case doLogin     //  登录
    case doResetPwd  //  忘记密码
    case donext //  下一步
    case close //  下一步
    case doJoin  //加入你好网红
 
}
class ContainVC: UIViewController {

    var scrollView : UIScrollView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(_:)), name: Notification.Name(rawValue:AppConst.WechatKey.ErrorCode), object: nil)
       initUI()
        
        // Do any additional setup after loading the view.
    }
       //MARK:-  登录成功
    func loginSuccess(_ notice: NSNotification) {
        
        let weChatLoginRequestModel = WeChatLoginRequestModel()
        weChatLoginRequestModel.openid = ShareDataModel.share().wechatUserInfo[SocketConst.Key.openid]!
        weChatLoginRequestModel.deviceId = "123"
        
        AppAPIHelper.login().WeChatLogin(model: weChatLoginRequestModel, complete: {[weak self] (result) in
            
            if let response = result as? StarUserModel {
                
                if (response.result == -302) {
                    ShareDataModel.share().isweichaLogin = true
                    self?.scrollView?.setContentOffset(CGPoint.init(x: (self?.scrollView?.width)!, y: 0), animated: true)
                } else {
                    AppConfigHelper.shared().updateDeviceToken()
                    UserDefaults.standard.set(response.userinfo?.phone, forKey: "phone")
                    UserDefaults.standard.set(response.token, forKey: "token")
                    StarUserModel.upateUserInfo(userObject: response)
                    self?.dismissController()
                }
            }
          
        }) { (error) in
            ShareDataModel.share().isweichaLogin = true
            self.scrollView?.setContentOffset(CGPoint.init(x: (self.scrollView?.frame.size.width)!, y: 0), animated: true)
        }
        


    }
    
   //MARK:- 设置UI
    func initUI(){
        
        self.automaticallyAdjustsScrollViewInsets = false;
        //登录视图
        scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.scrollView?.isScrollEnabled = false
        scrollView?.isPagingEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView?.contentSize = CGSize.init(width: self.view.frame.size.width*2, height: 0)
        view.addSubview(scrollView!)
        scrollView?.isPagingEnabled = true
        let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.resultBlock = { [weak self](result) in
            
            switch result as! doStateClick {
            case .doResetPwd:
                
                let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ForgotPwdVC")
                self?.navigationController?.pushViewController(vc, animated: true)
                break
                //
            default:
                  self?.scrollView?.setContentOffset(CGPoint.init(x: (self?.scrollView?.frame.size.width)!, y: 0), animated: true)
            }
         
        }
        scrollView?.backgroundColor = UIColor.clear
        scrollView?.addSubview(vc.view)
        vc.view.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: ((self.scrollView?.frame.size.height)!+10))
        
        self.addChildViewController(vc)
        //注册视图
        let rvc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "RegistVC") as! RegistVC
        self.scrollView?.addSubview(rvc.view)
        rvc.view.frame = CGRect.init(x:  vc.view.frame.size.width, y: -10, width: vc.view.frame.size.width, height: ((self.scrollView?.frame.size.height)!+10))
        rvc.resultBlock = { [weak self](result) in
            switch result as! doStateClick {
                case .doResetPwd:
                    
                    let vc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ForgotPwdVC")
                    self?.navigationController?.pushViewController(vc, animated: true)
                    break
                case .doJoin:
                    self?.scrollView?.setContentOffset(CGPoint.init(x: (self?.scrollView?.frame.size.width)!*2 , y: 0), animated: true)
                    break
                default:
                    self?.scrollView?.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
            }
           
        }
        self.addChildViewController(rvc)
        
        //id视图
        let jvc = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "JoinVC") as! JoinVC
        self.scrollView?.addSubview(jvc.view)
        jvc.view.frame = CGRect.init(x:  vc.view.frame.size.width*2, y: -10, width: vc.view.frame.size.width, height: ((self.scrollView?.frame.size.height)!+10))
        jvc.resultBlock = { [weak self](result) in
            self?.scrollView?.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
        self.addChildViewController(jvc)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
  

}
