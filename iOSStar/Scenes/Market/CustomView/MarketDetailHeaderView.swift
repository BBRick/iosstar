//
//  MarketDetailHeaderView.swift
//  iOSStar
//
//  Created by J-bb on 17/6/6.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import Charts

class MarketDetailHeaderView: UIView {

    var timeLineView:LineChartView?
    var currentSubView:UIView?
    var menuView:YD_VMenuView?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panGesAction(sender:)))
        
        timeLineView?.addGestureRecognizer(panGes)
        
        

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func panGesAction(sender:UIPanGestureRecognizer) {
        
//        let point = sender.translation(in: timeLineView)
        
    }
    
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != nil else {
            return nil
        }
        if view!.isKind(of: UIButton.self) {
            return view
        }
        if menuView != nil {            
            if view!.isDescendant(of: menuView!) {
                return view
            }
        }
        if timeLineView != nil {
            if view!.isDescendant(of: timeLineView!) {
                
                return view
            }
        }
        
        if (view?.isDescendant(of: self))! {
            return currentSubView
        }

        return view
    }


}
