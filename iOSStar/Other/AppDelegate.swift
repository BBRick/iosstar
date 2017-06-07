//
//  AppDelegate.swift
//  iosblackcard
//
//  Created by J-bb on 17/4/13.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications

// 个推信息
let kGtAppId:String = "STxLopLZK0AFPvAcnu7o67"
let kGtAppKey:String = "SIbhyImzug9sjKteFtLrj8"
let kGtAppSecret:String = "TgaFdlcYMX5QVhH1CkP1k2"


import Alamofire
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,WXApiDelegate,GeTuiSdkDelegate,UNUserNotificationCenterDelegate{

    var window: UIWindow?
 
    var sdkConfigDelegate: NTESSDKConfigDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
         let config = BugoutConfig.default()
         config?.enabledShakeFeedback = true
         Bugout.init("aebdfa2eada182ab8dc7d44fd02a8c50", channel: "channel", config: config)
        
        sdkConfigDelegate = NTESSDKConfigDelegate.init()

        NIMSDKConfig.shared().delegate = sdkConfigDelegate
        NIMSDKConfig.shared().shouldSyncUnreadCount = true
        AppConfigHelper.shared().setupNIMSDK(sdkConfigDelegate:sdkConfigDelegate)
        AppConfigHelper.shared().setupUMSDK()
        NIMSDK.shared().register(withAppID: "9c3a406f233dea0d355c6458fb0171b8", cerName: "")
        NIMCustomObject.registerCustomDecoder(NTESCustomAttachmentDecoder())
        WXApi.registerApp("wx9dc39aec13ee3158")
      
        // MARK: -个推
        // [ GTSdk ]：是否允许APP后台运行
        GeTuiSdk.runBackgroundEnable(true);
        
        // [ GTSdk ]：是否运行电子围栏Lbs功能和是否SDK主动请求用户定位
        GeTuiSdk.lbsLocationEnable(true, andUserVerify: true);
        
        // [ GTSdk ]：自定义渠道
        GeTuiSdk.setChannelId("GT-Channel");
        
        // [ GTSdk ]：使用APPID/APPKEY/APPSECRENT启动个推
        GeTuiSdk.start(withAppId: kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self);
        
        // 注册APNs - custom method - 开发者自定义的方法
        self.registerRemoteNotification();
        
        
        login()

        
       
// /       [[NIMSDKConfig sharedConfig] setShouldSyncUnreadCount:YES];
        UIApplication.shared.statusBarStyle = .default

        return true
    }
    func login(){
        
        if  UserDefaults.standard.object(forKey: "phone") as? String == nil {
            return
        }
        AppAPIHelper.user().tokenLogin(complete: { (result) in
            let datadic = result as? UserModel
            if let _ = datadic {
           
                UserModel.share().upateUserInfo(userObject: result!)
                UserDefaults.standard.synchronize()
                self.LoginYunxin()
            }
        }) { (error ) in
            
        }
        
    }
    func LoginYunxin(){
        
        AppAPIHelper.login().registWYIM(phone: UserDefaults.standard.object(forKey: "phone") as! String, token: UserDefaults.standard.object(forKey: "phone")! as! String, complete: { (result) in
                let datadic = result as? Dictionary<String,String>
                if let _ = datadic {
                   
                    NIMSDK.shared().loginManager.login(UserDefaults.standard.object(forKey: "phone") as! String, token: (datadic?["token_value"]!)!, completion: { (error) in
                        if (error == nil){
                            
                              NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.loginSuccess), object: nil, userInfo:nil)
                        }
                
                        print(error)
                    })
            }
        }) { (error)  in
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        WXApi.handleOpen(url, delegate: self)
        return true
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
       
            WXApi.handleOpen(url, delegate: self)
        
        return true
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  
        
        // 支付返回
     func onResp(_ resp: BaseResp!) {
            //微信登录返回
            if resp.isKind(of: SendAuthResp.classForCoder()) {
                let authResp:SendAuthResp = resp as! SendAuthResp
                if authResp.errCode == 0{
                    accessToken(code: authResp.code)
                }
                return
            }
            else{
                if resp.isKind(of: PayResp.classForCoder()) {
                    let authResp:PayResp = resp as! PayResp
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.WechatPay.WechatKeyErrorCode), object: NSNumber.init(value: authResp.errCode), userInfo:nil)
                    
                    return
                }
            }
        }
        
        func accessToken(code: String)
        {
            let param = [SocketConst.Key.appid : AppConst.WechatKey.Appid,
                         "code" : code,
                         SocketConst.Key.secret : AppConst.WechatKey.Secret,
                         SocketConst.Key.grant_type : "authorization_code"]
            
            Alamofire.request(AppConst.WechatKey.AccessTokenUrl, method: .get, parameters: param).responseJSON { [weak self](result) in
                if let resultJson = result.result.value as? [String: AnyObject] {
                    if let errCode = resultJson["errcode"] as? Int{
                        print(errCode)
                    }
                    if let access_token = resultJson[SocketConst.Key.accessToken] as? String {
                        if let openid = resultJson[SocketConst.Key.openid] as? String{
                          self?.wechatUserInfo(token: access_token, openid: openid)
                         

                        }
                    }
                }
            }
    }
    func wechatUserInfo(token: String, openid: String)
    {
        let param = [SocketConst.Key.accessToken : token,
                     SocketConst.Key.openid : openid]
        Alamofire.request(AppConst.WechatKey.wechetUserInfo, method: .get, parameters: param).responseJSON {(result) in
            guard let resultJson = result.result.value as? [String: AnyObject] else{return}
            if let errCode = resultJson["errcode"] as? Int{
                print(errCode)
            }
            if let nickname = resultJson[SocketConst.Key.nickname] as? String {
              ShareDataModel.share().wechatUserInfo[SocketConst.Key.nickname] = nickname
            }
            if let openid = resultJson[SocketConst.Key.openid] as? String{
                ShareDataModel.share().wechatUserInfo[SocketConst.Key.openid] = openid
            }
            if let headimgurl = resultJson[SocketConst.Key.headimgurl] as? String{
                ShareDataModel.share().wechatUserInfo[SocketConst.Key.headimgurl] = headimgurl
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.WechatKey.ErrorCode), object: nil, userInfo:nil)
         }
         }
    
    // MARK: - 注册用户通知(推送)
    func registerRemoteNotification() {
        /*
         警告：Xcode8的需要手动开启“TARGETS -> Capabilities -> Push Notifications”
         */
        
        /*
         警告：该方法需要开发者自定义，以下代码根据APP支持的iOS系统不同，代码可以对应修改。
         以下为演示代码，仅供参考，详细说明请参考苹果开发者文档，注意根据实际需要修改，注意测试支持的iOS系统都能获取到DeviceToken。
         */
        
        let systemVer = (UIDevice.current.systemVersion as NSString).floatValue;
        if systemVer >= 10.0 {
            if #available(iOS 10.0, *) {
                let center:UNUserNotificationCenter = UNUserNotificationCenter.current()
                center.delegate = self;
                center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted:Bool, error:Error?) -> Void in
                    if (granted) {
                        print("注册通知成功") //点击允许
                    } else {
                        print("注册通知失败") //点击不允许
                    }
                })
                
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                if #available(iOS 8.0, *) {
                    let userSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(userSettings)
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            };
        }else if systemVer >= 8.0 {
            if #available(iOS 8.0, *) {
                let userSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(userSettings)
                
                UIApplication.shared.registerForRemoteNotifications()
            }
        }else {
            if #available(iOS 7.0, *) {
                UIApplication.shared.registerForRemoteNotifications(matching: [.alert, .sound, .badge])
            }
        }
    }
    
    // MARK: - 远程通知(推送)回调
    /** 远程通知注册成功委托 */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceToken_ns = NSData.init(data: deviceToken);    // 转换成NSData类型
        var token = deviceToken_ns.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>"));
        token = token.replacingOccurrences(of: " ", with: "")
        
        // [ GTSdk ]：向个推服务器注册deviceToken
        GeTuiSdk.registerDeviceToken(token);
        
        NSLog("\n>>>[DeviceToken Success]:%@\n\n",token);
    }
    
    /** 远程通知注册失败委托 */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\n>>>[DeviceToken Error]:%@\n\n",error.localizedDescription);
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // 唤醒
        GeTuiSdk.resume()
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: - APP运行中接收到通知(推送)处理 - iOS 10 以下
    
    /** APP已经接收到“远程”通知(推送) - (App运行在后台) */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        application.applicationIconBadgeNumber = 0;        // 标签
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // [ GTSdk ]：将收到的APNs信息传给个推统计
        GeTuiSdk.handleRemoteNotification(userInfo);
        
        NSLog("\n>>>[Receive RemoteNotification]:%@\n\n",userInfo);
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("willPresentNotification: %@",notification.request.content.userInfo);
        
        completionHandler([.badge,.sound,.alert]);
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("didReceiveNotificationResponse: %@",response.notification.request.content.userInfo);
        
        // [ GTSdk ]：将收到的APNs信息传给个推统计
        GeTuiSdk.handleRemoteNotification(response.notification.request.content.userInfo);
        
        
        if UIApplication.shared.applicationState == .active {
            
            let alertController = UIAlertController(title: "提示", message: "你确定要退出吗？", preferredStyle:.alert)
            // 设置2个UIAlertAction
            let cancelAction = UIAlertAction(title: "取消", style:.cancel, handler: nil)
            let completeAction = UIAlertAction(title: "确定", style:.default) { (UIAlertAction) in
            }
            
            // 添加
            alertController.addAction(cancelAction)
            alertController.addAction(completeAction)
            
            // 弹出
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }
        
        completionHandler();
    }
    
    // MARK: - GeTuiSdkDelegate
    
    /**
     
    /** SDK启动成功返回cid */
    func geTuiSdkDidRegisterClient(_ clientId: String!) {
        // [4-EXT-1]: 个推SDK已注册，返回clientId
        NSLog("\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
        
    }
    /** SDK遇到错误回调 */
    func geTuiSdkDidOccurError(_ error: Error!) {
        // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
        NSLog("\n>>>[GeTuiSdk error]:%@\n\n", error.localizedDescription);
    }
    
    /** SDK收到sendMessage消息回调 */
    func geTuiSdkDidSendMessage(_ messageId: String!, result: Int32) {
        // [4-EXT]:发送上行消息结果反馈
        let msg:String = "sendmessage=\(messageId),result=\(result)";
        NSLog("\n>>>[GeTuiSdk DidSendMessage]:%@\n\n",msg);
    }
    
    /** SDK收到透传消息回调 */
    func geTuiSdkDidReceivePayloadData(_ payloadData: Data!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        
        var payloadMsg = "";
        if((payloadData) != nil) {
            payloadMsg = String.init(data: payloadData, encoding: String.Encoding.utf8)!;
        }
        
        let msg:String = "Receive Payload: \(payloadMsg), taskId:\(taskId), messageId:\(msgId)";
        
        NSLog("\n>>>[GeTuiSdk DidReceivePayload]:%@\n\n",msg);
    }
     
    */
    
}

    
