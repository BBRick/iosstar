//
//  YD_CountDownHelper.swift
//  TestCountDown
//
//  Created by J-bb on 17/2/9.
//  Copyright © 2017年 J-bb. All rights reserved.
//

import UIKit


class YD_CountDownHelper: NSObject {

    
    static let shared = YD_CountDownHelper()
    
    private override init() {}
    
    
    var timeDistance:Int64 = 0
    var timer:CADisplayLink?
    var isCountDown = false
    
    var countDownRefresh:CompleteBlock?
    
    var auctionRefresh:CompleteBlock?
    
    var marketListRefresh:CompleteBlock?
    
    var marketTimeLineRefresh:CompleteBlock?
    
    var marketBuyOrSellListRefresh:CompleteBlock?
    
    var marketInfoRefresh:CompleteBlock?
    
    var voiceDidPlaying:CompleteBlock?
    
    var barrageRefresh:CompleteBlock?

    //行情刷新轮询标记
    var marketIdentifier = 0
    //行情刷新轮询标记最大值
    private var maxCount = 3
    var indexIdentifier = 0
    private var maxIndex = 2
    
    func countDown() {
        
        if voiceDidPlaying != nil{
         countDownRefresh!(nil)
        }
        //倒计时
        if countDownRefresh != nil {
            countDownRefresh!(nil)
        }
        indexIdentifier += 1
        if indexIdentifier == maxIndex {
            if barrageRefresh != nil {
                barrageRefresh!(nil)
            }
            indexIdentifier = 0
        }

        //行情数据 多秒刷新
        marketIdentifier += 1
        if marketIdentifier == maxCount {
            marketRefresh()
            marketIdentifier = 0
        }
    }
    
    
    
    func marketRefresh() {
        
        if auctionRefresh != nil {
            auctionRefresh!(nil)
        }
        if marketListRefresh != nil {
            marketListRefresh!(nil)
        }
        if marketTimeLineRefresh != nil {
            marketTimeLineRefresh!(nil)
        }
        if marketBuyOrSellListRefresh != nil {
            marketBuyOrSellListRefresh!(nil)
        }
        if marketInfoRefresh != nil {
            marketInfoRefresh!(nil)
        }
    }

    
    func getResidueCount(closeTime:Int) -> Int {
        return  closeTime - Int(NSDate().timeIntervalSince1970) - Int(timeDistance)
    }
    
    func getTextWithStartTime(closeTime:Int) -> String{
        
        let count = getResidueCount(closeTime: closeTime)
        
        if count < 0 {
            return "回收未开始"
        }
        return getTextWithTimeCount(timeCount: count)
    }
    
    func getTextWithTimeCount(timeCount:Int, formatString:String = "%.2d:%.2d:%.2d") -> String {
        let hours = timeCount / 3600
        let minutes = (timeCount % 3600) / 60
        let seconds = timeCount % 60
        return String(format: formatString, hours, minutes, seconds)
    }
    

    func resetDataSource() {

    }
    
    func reStart() {
        resetDataSource()
        if timer != nil {
            start()
        }
    }
    
    func start() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = CADisplayLink(target: self, selector: #selector(countDown))
        timer?.frameInterval = 60
        timer?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func pause() {
        timer?.invalidate()
    }
    func stop() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
