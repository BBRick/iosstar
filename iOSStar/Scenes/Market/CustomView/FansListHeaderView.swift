//
//  FansListHeaderView.swift
//  iOSStar
//
//  Created by J-bb on 17/5/19.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
protocol SelectFansDelegate {
    func selectAtIndex(index:Int)
}
class FansListHeaderView: UITableViewHeaderFooterView {
    
    var currentSelectIndex = 0
    var delegate:SelectFansDelegate?
    lazy var buyButton:UIButton = {
        let button = UIButton(type: .custom)
        button.tag = 2222
        button.setTitle("获取榜单", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        button.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        return button
    }()
    lazy var sellButton:UIButton = {
       let button = UIButton(type: .custom)
        button.tag = 2223
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        button.setTitle("回收榜单", for: .normal)
        button.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        return button
    }()
    
    lazy var backView:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(hexString: "ECECEC")
        return view
    }()
    
    lazy var imageView:UIImageView = {
       let imageView = UIImageView(image: UIImage.init(named: "fanslist_bangdan"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var isShowImage = false {
        didSet {
            imageView.isHidden = !isShowImage
            
            if !isShowImage {
                buyButton.snp.remakeConstraints({ (make) in
                    make.centerX.equalTo(kScreenWidth / 4)
                    make.centerY.equalTo(self)
                })
                sellButton.snp.remakeConstraints({ (make) in
                    make.centerX.equalTo(kScreenWidth / 4 * 3)
                    make.centerY.equalTo(buyButton)
                })
            }
        }
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
     
        contentView.backgroundColor = UIColor(hexString: "fafafa")
        addSubview(buyButton)
        addSubview(sellButton)
        addSubview(backView)
        backView.addSubview(imageView)
        buyButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(kScreenWidth / 4 + 5)
            make.centerY.equalTo(self)
        }
        sellButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(kScreenWidth / 4 * 3 + 5)
            make.centerY.equalTo(buyButton)
        }
        backView.snp.makeConstraints { (make) in
            make.centerX.equalTo(kScreenWidth / 4 - 4)
            make.centerY.equalTo(buyButton.snp.centerY)
            make.width.equalTo(80)
            make.height.equalTo(23)
        }
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(backView)
            make.centerY.equalTo(backView.snp.centerY).offset(-6)
        }
        bringSubview(toFront: buyButton)
        bringSubview(toFront: sellButton)
        buyButton.addTarget(self, action: #selector(selectAtIndex(sender:)), for: .touchUpInside)
        sellButton.addTarget(self, action: #selector(selectAtIndex(sender:)), for: .touchUpInside)
    }
    
    func settitles(titles:[String]) {
        buyButton.setTitle(titles.first, for: .normal)
        sellButton.setTitle(titles.last, for: .normal)
    }
    
    func selectIndex(index:Int) {

        currentSelectIndex = index
        var x:CGFloat = 0.0
        if index == 0 {
            x = kScreenWidth * 0.25
        } else {
            x = kScreenWidth * 0.75
        }
        backView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(x)
            make.centerY.equalTo(buyButton.snp.centerY)
            make.width.equalTo(80)
            make.height.equalTo(23)
        }
        self.backView.setNeedsDisplay()
        self.backView.setNeedsLayout()

    }
    
    func selectAtIndex(sender:UIButton) {
        let index = sender.tag - 2222
        
//        if index == currentSelectIndex {
//            return
//        }
        currentSelectIndex = index

        var x:CGFloat = 0.0
        if index == 0 {
            x = kScreenWidth * 0.25
        } else {
            x = kScreenWidth * 0.75
        }
        UIView.animate(withDuration: 0.5) { 
            self.backView.center = CGPoint(x: x, y: self.backView.center.y)
        }
        delegate?.selectAtIndex(index: index)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
