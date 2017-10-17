//
//  ExchangeViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/4/20.
//  Copyright © 2017年 sum. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController ,UITabBarControllerDelegate,NIMSystemNotificationManagerDelegate,NIMConversationManagerDelegate{
    
    var needPwd :Int = 2
    var realName :Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //为了添加判断来请求防止崩溃
        if checkLogin()
        {
            self.getUserInfo { [weak self ](result) in
                if let response =  result{
                    let object = response as! UserInfoModel
                    self?.needPwd = object.is_setpwd
                    
                }
            }
            
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
        }
    }
    
    // 订单列表Action
    @IBAction func toOrderList(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Exchange", bundle: nil).instantiateViewController(withIdentifier: "SystemMessageVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // 网红通讯录Action
    @IBAction func toStarContacts(_ sender: UIButton) {
        
        if self.needPwd == 1 {
           showopenPay()
        }else{
         
            if realName {
                showRealname()
            }
            else {
                let vc = UIStoryboard.init(name: "Exchange", bundle: nil).instantiateViewController(withIdentifier: "ContactListViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "连接网红"
    }
    
}




