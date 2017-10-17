//
//  UIViewController+Extension.swift
//  viossvc
//
//  Created by yaowang on 2016/10/31.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation
import RealmSwift
//import XCGLogger
import SVProgressHUD
extension UIViewController {
    
    class func storyboardInit(identifier:String, storyboardName:String) -> UIViewController? {
        let storyBoard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: identifier)
    }
    func errorBlockFunc()->ErrorBlock {
        return { [weak self] (error) in
            //            XCGLogger.error("\(error) \(self)")
            
            self?.didRequestError(error)
        }
    }
    func LoginSuccess(){
        
        
    }
    
    
    func didRequestError(_ error:NSError) {
        if error.code == -11011 {
            return
        }
        SVProgressHUD.showErrorMessage(ErrorMessage: error.localizedDescription, ForDuration: 1.5, completion: nil)
    }
    
    func showErrorWithStatus(_ status: String!) {
        SVProgressHUD.showErrorMessage(ErrorMessage: status, ForDuration: 1.5, completion: nil)
    }
    
    func showWithStatus(_ status: String!) {
        SVProgressHUD.show(withStatus: status)
    }
    
    func showUpdateInfo() {

    }
    //检查是否已登录
    func checkLogin() -> Bool {
        
        if UserDefaults.standard.object(forKey: "phone") as? String == nil {
            let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
            let controller = storyboard.instantiateInitialViewController()
            controller?.modalPresentationStyle = .custom
            controller?.modalTransitionStyle = .crossDissolve
            present(controller!, animated: true, completion: nil)
            
            return false
        }else{
            return true
        }
    }
    
    
    
    
    
    // 显示引导视图控制器
    func showGuideVC(_ guideType:AppConst.guideKey, handle:CompleteBlock?) {
        
        let vc = GuideVC()
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.handleBlock = handle
        vc.setGuideContent(guideType)
        present(vc, animated: true, completion: nil)
    }
    
    //退出登录
    func userLogout() {
        if let tabbar = UIApplication.shared.windows[0].rootViewController as? BaseTabBarController{
            //为了让退回跟视图
            if let nav : UINavigationController = tabbar.selectedViewController as? UINavigationController{
                if nav.viewControllers.count > 0{
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
            }
            DispatchQueue.main.async {
                tabbar.selectedIndex = 0
            }
        }
        if let phoneString = UserDefaults.standard.object(forKey: "phone") as? String {
            UserDefaults.standard.set(phoneString, forKey: "lastLogin")
        }
        UserDefaults.standard.removeObject(forKey:"phone")
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    //检查text是否为空
    func checkTextFieldEmpty(_ array:[UITextField]) -> Bool {
        for  textField in array {
            if  textField.text == ""  {
                SVProgressHUD.showErrorMessage(ErrorMessage: textField.placeholder!, ForDuration: 2.0, completion: {
                });
                return false
            }
        }
        return true
    }
    //关闭模态视图控制器
    func dismissController() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    //打电话
    func didActionTel(_ telPhone:String) {
        let alert = UIAlertController.init(title: "呼叫", message: telPhone, preferredStyle: .alert)
        let ensure = UIAlertAction.init(title: "确定", style: .default, handler: { (action: UIAlertAction) in
            UIApplication.shared.openURL(URL(string: "tel://\(telPhone)")!)
        })
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (action: UIAlertAction) in
            
        })
        alert.addAction(ensure)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    //导航栏透明
    func translucent(clear: Bool) {
        
        navigationController?.navigationBar.isTranslucent = clear;
        
    }
    
    //MARK: -- 隐藏tabBar导航栏
    func hideTabBarWithAnimationDuration() {
        let tabBar = self.tabBarController?.tabBar
        let parent = tabBar?.superview
        let content = parent?.subviews[0]
        let window = parent?.superview
        if window != nil {
            var tabFrame = tabBar?.frame
            tabFrame?.origin.y = (window?.bounds)!.maxY
            tabBar?.frame = tabFrame!
            content?.frame = (window?.bounds)!
        }
        
    }
    func setCustomTitle(title:String) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(hexString: AppConst.Color.main)
        navigationItem.titleView = label
        
    }
    func showTabBarWithAnimationDuration() {
        let tabBar = self.tabBarController?.tabBar
        let parent = tabBar?.superview
        let content = parent?.subviews[0]
        let window = parent?.superview
        if window != nil {
            var tabFrame = tabBar?.frame
            tabFrame?.origin.y = (window?.bounds)!.maxY - ((tabBar?.frame)?.height)!
            tabBar?.frame = tabFrame!
            
            var contentFrame = content?.frame
            contentFrame?.size.height -= (tabFrame?.size.height)!
        }
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
    }
    //判断是否实名认证
    func checkVaildName(complete: CompleteBlock?){
        
        
    }
    func getUserRealmInfo(complete: CompleteBlock?){
        let requestModel = GetAuthenticationRequestModel()
        
        AppAPIHelper.user().requestAuthentication(requestModel: requestModel, complete: { (result) in
            complete?(result as AnyObject)
        }) { (error) in
            //            SVProgressHUD.showErrorMessage(ErrorMessage: error.userInfo["NSLocalizedDescription"] as! String, ForDuration: 2.0, completion: nil)
        }
    }
    
    
    func getUserInfo(complete: CompleteBlock?){
        
        if UserDefaults.standard.object(forKey: "phone") as? String != nil{
            
            let requestModel = UserInfoRequestModel()
            AppAPIHelper.user().requestUserInfo(requestModel: requestModel, complete: { (result) in
                complete?(result as AnyObject)
            }, error: { (error) in

                //刷新下token
                AppConfigHelper.shared().login()
                //               self.userLogout()
            })
            
        }
    }
    //获取网红姓名
    func getStartName(startCode:String,complete: CompleteBlock?){
        
        let realm = try! Realm()
        let filterStr = "code = \(startCode)"
        let user = realm.objects(StartModel.self).filter(filterStr).first
        if user != nil{
            complete?(user as AnyObject)
        }else{
            complete?(nil)
        }
    }
    
    func showOnlyLogin(){
        userLogout()
        let onlyLoginAlter = UIAlertController.init(title: "被迫下线", message: "您的账号在另一地点登录，您已被迫下线", preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "确定", style: .default, handler: nil)
        onlyLoginAlter.addAction(sureAction)
        DispatchQueue.main.async {
            self.present(onlyLoginAlter, animated: true, completion: nil)
        }
    }
    
    func gethelp(){
        if let helpVC = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: CustomerServiceVC.className()) as? CustomerServiceVC{
            if let nav = tabBarController?.selectedViewController as? UINavigationController{
                nav.pushViewController(helpVC, animated: true)
            }
        }
    }
    func showopenPay(){
        let alertVc = AlertViewController()
        alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                            
                            titleLabelText: "开通支付",
                            subTitleText: "需要开通支付才能进行充值等后续操作。\n开通支付后，您可以获取网红时间，回收网红时间，\n和网红在‘连接网红’中聊天，并且还能连接网红。",
                            completeButtonTitle: "我 知 道 了") {[weak alertVc] (completeButton) in
                                alertVc?.dismissAlertVc()
                                
                                
                                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "TradePassWordVC")
                                self.navigationController?.pushViewController(vc, animated: true )
                                return
        }
    }
    func showRealname(){
        let alertVc = AlertViewController()
        alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                            titleLabelText: "您还没有身份验证",
                            subTitleText: "您需要进行身份验证,\n之后才可以进行网红时间回购",
                            completeButtonTitle: "开 始 验 证") {[weak alertVc] (completeButton) in
                                alertVc?.dismissAlertVc()
                                
                                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "VaildNameVC")
                                self.navigationController?.pushViewController(vc, animated: true )
                                return
        }
    }
    func showbankCard(){
        let alertVc = AlertViewController()
        alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                            titleLabelText: "您还没有绑定银行卡",
                            
                            subTitleText: "您需要银行卡进行网红时间回购",
                            completeButtonTitle: "开 始 绑 定") {[weak alertVc] (completeButton) in
                                alertVc?.dismissAlertVc()
                                
                                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "BindingBankCardVC")
                                self.navigationController?.pushViewController(vc, animated: true )
                                return
        }
        
    }
    //进入播放页面
    func pushViewController(pushSreing:String,videdoUrl : String,pushModel:UserAskDetailList,withImg:String,complete: CompleteBlock?){
        if pushSreing == "PlaySingleVC" {
            if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: pushSreing) as? PlaySingleVC{
                vc.startModel = pushModel
                
                present(vc, animated: true, completion: {
                    vc.play(videdoUrl)
                })
                
                vc.setimg(withImg)
                vc.resultBlock = { (result ) in
                    complete?(result)
                }
            }
            
        }
        if pushSreing == "PlayVideoVC" {
            
            if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: PlayVideoVC.className()) as? PlayVideoVC{
                vc.startModel = pushModel
//                vc.setimg(withImg)
                present(vc, animated: true, completion: {
                    vc.play(videdoUrl)
                })
                vc.resultBlock = { (result ) in
                    complete?(result)
                }
            }
        }
        
    }
    //进入播放页面
    func pushcontroller(pushSreing:String,model : UserAskDetailList,playString:String){
        self.pushViewController(pushSreing: pushSreing, videdoUrl:  ShareDataModel.share().qiniuHeader + playString , pushModel: model, withImg: model.thumbnailS != "" ? model.thumbnailS  :  "1123.png" , complete: { (result) in
            if let vc = UIStoryboard.init(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "VideoAskQuestionsVC") as? VideoAskQuestionsVC{
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    
    }
}

