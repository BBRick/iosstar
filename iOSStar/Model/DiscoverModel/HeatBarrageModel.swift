//
//  BarrageInfo.swift
//  iOSStar
//
//  Created by sum on 2017/7/17.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
class HeatBarrageModel: BaseModel {
    
    var pos = 0
    var count = 0
}
class BarrageListModel: NSObject {
    
    var order_type: Int64 = 0         //1.回收 2.获取
    var order_num: Int64 = 0          // 数量
    var order_price: Double = 0       // 价格
    var head_url : String = ""        // 用户头像
    var user_name : String = ""       // 用户名

}
class BarrageInfo: BaseModel {
    
    var positionsList : [FansListModel]?
    
    class func positionsListModelClass() ->AnyClass {
        return  FansListModel.classForCoder()
    }
}

