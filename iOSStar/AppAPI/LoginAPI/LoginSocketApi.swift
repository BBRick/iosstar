//
//  LoginSocketApi.swift
//  wp
//
//  Created by 木柳 on 2016/12/21.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit

class LoginSocketApi: BaseSocketAPI, LoginApi {
 
    //注册
    func regist(phone: String, password: String, complete: CompleteBlock?, error: ErrorBlock?){
        
        let param: [String: Any] = [SocketConst.Key.phone: "18643803462",
                                    SocketConst.Key.pwd:  password,
                                    SocketConst.Key.memberId: 1001,
                                    SocketConst.Key.agentId:  "186681261",
                                    SocketConst.Key.recommend: "3tewe",
                                    SocketConst.Key.timestamp: 100088888]
        print(param)
        let packet: SocketDataPacket = SocketDataPacket.init(opcode: .register, dict: param as [String : AnyObject])
        
       startRequest(packet, complete: complete, error: error)
    }
    
    func registWYIM(phone: String, token: String, complete: CompleteBlock?, error: ErrorBlock?){
        let param: [String: Any] = [SocketConst.Key.phone: "18643803462",
                                    SocketConst.Key.pwd:  token,
                                    SocketConst.Key.memberId: 1001,
                                    SocketConst.Key.agentId:  "186681261",
                                    SocketConst.Key.recommend: "3tewe",
                                    SocketConst.Key.timestamp: 100088888]
        print(param)
        let packet: SocketDataPacket = SocketDataPacket.init(opcode: .registWY, dict: param as [String : AnyObject])
        
        startRequest(packet, complete: complete, error: error)
    }
    //登录
    func login(phone: String, password: String, complete: CompleteBlock?, error: ErrorBlock?){
        let param: [String: Any] = [SocketConst.Key.phone: "18643803462",
                                    SocketConst.Key.pwd:  password,
                                    SocketConst.Key.deviceId: "deviceId"]
        print(param)
        let packet: SocketDataPacket = SocketDataPacket.init(opcode: .login, dict: param as [String : AnyObject])
        
        startRequest(packet, complete: complete, error: error)
    }
    //微信绑定
      func BindWeichat(phone: String, timeStamp: Int,vToken: String,pwd: String,openid: String,nickname: String,headerUrl: String,memberId: Int,agentId: String,recommend: String,deviceId: String,vCode: String, complete: CompleteBlock?, error: ErrorBlock?){
    
        let param: [String: Any] = [SocketConst.Key.vCode: vCode,
                                    SocketConst.Key.timestamp:  timeStamp,
                                    SocketConst.Key.vToken: vToken,
                                    SocketConst.Key.phone: phone,
                                    SocketConst.Key.pwd: pwd,
                                    SocketConst.Key.openid: openid,
                                    SocketConst.Key.nickname: nickname,
                                    SocketConst.Key.headerUrl: headerUrl,
                                    SocketConst.Key.memberId: memberId,
                                    SocketConst.Key.agentId: agentId,
                                    SocketConst.Key.recommend: recommend,
                                    SocketConst.Key.deviceId: deviceId,
                                    ]
        print(param)
        let packet: SocketDataPacket = SocketDataPacket.init(opcode: .bindWchat, dict: param as [String : AnyObject])
        
        startRequest(packet, complete: complete, error: error)
    }
    func WeichatLogin(openid: String, deviceId: String, complete: CompleteBlock?, error: ErrorBlock?){
        let param: [String: Any] = [SocketConst.Key.openid: openid,
                                    SocketConst.Key.deviceId:  deviceId,
                                    ]
       
        let packet: SocketDataPacket = SocketDataPacket.init(opcode: .WchatLogin, dict: param as [String : AnyObject])
        
        startRequest(packet, complete: complete, error: error)
    
    }
   
}
