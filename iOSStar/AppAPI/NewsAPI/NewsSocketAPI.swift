//
//  NewsSocketAPI.swift
//  iOSStar
//
//  Created by J-bb on 17/5/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class NewsSocketAPI: BaseSocketAPI, NewsApi {

    func requestNewsList(startnum:Int, endnum:Int, complete: CompleteBlock?, error: ErrorBlock?) {
        let parameters:[String:Any] = [SocketConst.Key.name : "1",
                                       SocketConst.Key.starCode : "1",
                                       SocketConst.Key.startnum : startnum,
                                       SocketConst.Key.endnum : endnum,
                                       SocketConst.Key.all : 1]
        
        let packet = SocketDataPacket(opcode: .newsInfo, dict: parameters as [String : AnyObject], type: .news)
        startModelsRequest(packet, listName: "list", modelClass: NewsModel.self, complete: complete, error: error)
    }
    
    func requestBannerList(complete: CompleteBlock?, error: ErrorBlock?) {
        let parameters:[String:Any] = [SocketConst.Key.starCode : "1", SocketConst.Key.all : 1]
        let packet = SocketDataPacket(opcode: .banners, dict: parameters as [String : AnyObject], type: .news)
        
        startModelsRequest(packet, listName: "list", modelClass: BannerModel.self, complete: complete, error: error)
        


    }
    func requestStarInfo(code:String,complete: CompleteBlock?, error: ErrorBlock?) {
        let parameters:[String:Any] = [SocketConst.Key.starCode : code]
        let packet = SocketDataPacket(opcode: .starInfo, parameters: parameters)
        startModelRequest(packet, modelClass: BannerDetaiStarModel.self, complete: complete, error: error)
    }
}
