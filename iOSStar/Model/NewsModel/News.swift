
//
//  News.swift
//  iOSStar
//
//  Created by J-bb on 17/5/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import RealmSwift
import Foundation

class NewsModel: Object {
    dynamic var id = 0
    dynamic var link_url = ""
    dynamic var remarks = ""
    dynamic var showpic_url = ""
    dynamic var starcode = ""
    dynamic var subject_name = ""
    dynamic var times = ""
    
}

class BannerModel: Object {
    dynamic var code = ""
    dynamic var name = ""
    dynamic var pic_url = ""
    dynamic var type = 0
}

class BannerDetaiStarModel: Object {
    dynamic var constellaction = ""
    dynamic var birth = ""
    dynamic var colleage = ""
    dynamic var expeience = ""
    dynamic var introduction = ""
    dynamic var nation = ""
    dynamic var nationality = ""
    dynamic var pic_url = ""
    dynamic var work = ""
    dynamic var owntimes = 0
    dynamic var head_url = ""
    dynamic var weibo_index_id = ""
    dynamic var gender = 0
    dynamic var symbol = ""
}
