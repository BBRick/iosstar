//
//  ImageMenuCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/17.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class ImageMenuCell: UICollectionViewCell {

    lazy var iconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "8")
        imageView.isUserInteractionEnabled = true   
        return imageView
    }()
    var titleLabel:UILabel = {
       
        let label = UILabel()
        label.textColor = UIColor(hexString: AppConst.Color.main)
        label.text = "获取"
        label.font = UIFont.systemFont(ofSize: 10)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubView()
    }
    func addSubView() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.width.equalTo(22)
            make.centerX.equalTo(self)
            make.top.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(iconImageView)
            make.height.equalTo(10)
            make.top.equalTo(iconImageView.snp.bottom).offset(1)
        }
    }
    func setTitle(text:String)  {
        titleLabel.text = text
    }
    func setImage(image:UIImage?) {
        iconImageView.image = image
    }
}
