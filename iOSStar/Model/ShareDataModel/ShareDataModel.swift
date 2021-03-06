//
//  ShareDataModel.swift
//  iOSStar
//
//  Created by sum on 2017/4/24.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class ShareDataModel: NSObject {

    private static var model: ShareDataModel = ShareDataModel()
    class func share() -> ShareDataModel{
        return model
    }
    var wechatUserInfo = [String:String]()
    dynamic var isweichaLogin : Bool = false
    var phone : String =   ""
    var codeToeken : String =   ""
    dynamic var selectMonth : String = ""
    var isReturnBackClick : Bool = false
    var orderInfo : OrderInformation?
    var isShowInWindows : Bool = false
    var registerModel: RegisterRequestModel = RegisterRequestModel()
    var wxregisterModel: WXRegisterRequestModel = WXRegisterRequestModel()
    var controlSwitch: Bool = true
    var buttonExtOnceSwitch = true
    var voiceSwitch = false
    var baseTabbarC: BaseTabBarController?
}
class OrderInformation: NSObject {
    
     var orderAllPrice : String =   ""
     var orderAccount : String =   ""
     var orderPrice : String =   ""
     var orderStatus : String =   ""
     var orderInfomation : String =   ""
     var ordertitlename : String =   "订单详情"
    
    
}
