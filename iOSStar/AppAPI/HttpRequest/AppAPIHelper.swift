//
//  AppAPIHelper.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class AppAPIHelper: NSObject {
    
    fileprivate static var _userApi = LoginSocketApi()
    class func user() -> LoginApi{
        return _userApi
    }
}

