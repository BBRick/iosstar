//
//  SockOpcode.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import Foundation

class SocketConst: NSObject {
    enum OPCode:UInt16 {
        // 心跳包
        case heart = 1000
        // 获取图片上传token
        case imageToken = 1047
        // 错误码
        case errorCode = 0
        // 登录
        case login = 3003
        // 注册
        case register = 3001
        // 注册
        case reducetime = 9017
       //减少时间
        case getlist = 9013
        // 重设密码
        case repwd = 3019
        // 声音验证码
        case voiceCode = 1006
        // 设置用户信息
        case userInfo = 10010
        case bindWchat = 3015
        //设置账号信息
        case WchatLogin = 3013
        case verifycode = 3011
        //修改持仓
        case changeDeal = 2006
        //商品列表
        case products = 5001
        //当前K线数据
        case kChart = 4005
        //当前分时数据
        case timeline = 4003
        //当前报价
        case realtime = 4001
        //网易云
        case registWY = 9005
        //航运舱位
        case position = 5007
        //收益选择
        case benifity = 6007
        
        case balance = 7002
        
    }
    enum type:UInt8 {
        case error  = 0
        case wp     = 1
        case chat   = 2
        case user   = 3
        case time   = 4
        case deal   = 5
        case operate = 6
        case getlist = 9
    }
    
    enum aType:UInt8 {
        case shares = 1 //股票
        case spot = 2   //现货
        case futures = 3   //期货
        case currency = 4   //外汇
    }
    
    class Key {
       
    
        static let phone = "phone"
        static let pwd = "pwd"
        static let code = "vCode"
        static let appid = "appid"
        static let secret = "secret"
        static let grant_type = "grant_type"
        static let memberId = "memberId"
        static let agentId = "agentId"
        static let recommend = "recommend"
        static let status = "status"
        static let uid  = "uid"
        static let vToken = "vToken"
        static let avatarLarge = "avatarLarge"
        static let timestamp = "timeStamp"
        static let aType = "aType"
        static let name_value = "name_value"
        static let accid_value = "accid_value"
        static let deviceId = "deviceId"
        static let vCode = "vCode"
        static let openid = "openid"
        static let nickname = "nickname"
        static let headerUrl = "headerUrl"
        static let headimgurl = "headimgurl"
        static let accessToken = "access_token"
        static let accid = "accid"
        static let createtime = "createtime"
        static let starcode = "starcode"
   
        
    }
}
