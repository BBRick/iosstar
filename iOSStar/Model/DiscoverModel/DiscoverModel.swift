//
//  DiscoverModel.swift
//  iOSStar
//
//  Created by J-bb on 17/7/8.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import Foundation
import RealmSwift


class DiscoverListModel:BaseModel{
    
    var symbol_info:[StarSortListModel]?
    var home_last_pic = ""
    class func symbol_infoModelClass() ->AnyClass {
        return  StarSortListModel.classForCoder()
    }
}
class StarSortListModel: BaseModel {
    
     var wid = ""
     var name = ""
     var pic = ""
     var home_pic = ""
     var home_button_pic = ""
     var symbol = ""
     var currentPrice = 0.0
     var priceTime:Int64 = 0
     var sysTime:Int64 = 0
     var change = 0.0
     var pchg = 0.0
     var pushlish_type = 0
}
class BuyRemainingTimeModel: Object {
    dynamic var symbol = ""
    dynamic var remainingTime:Int64 = 0
}
class PanicBuyInfoModel: Object {
    dynamic var publish_price = 0.0
    dynamic var back_pic_url = ""
    dynamic var star_code = ""
    dynamic var star_name = ""
    dynamic var head_url = ""
    dynamic var star_type:Int64 = 0
    dynamic var publish_type:Int64 = 0
    dynamic var publish_time:Int64 = 0
    dynamic var publish_last_time:Int64 = 0
    dynamic var publish_begin_time:Int64 = 0
    dynamic var publish_end_time:Int64 = 0
}

class StarIntroduceResult: Object {
    dynamic var resultvalue:StarDetaiInfoModel?
}

class StarDetaiInfoModel: Object {
    dynamic var star_code = ""
    dynamic var star_name = ""
    dynamic var star_tpye:Int64 = 0
    dynamic var head_url = ""
    dynamic var back_pic = ""
    dynamic var portray1 = ""
    dynamic var portray2 = ""
    dynamic var portray3 = ""
    dynamic var portray4 = ""
    dynamic var acc_id = ""    
}

