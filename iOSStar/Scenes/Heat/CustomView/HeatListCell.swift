//
//  HeatListCell.swift
//  iOSStar
//
//  Created by J-bb on 17/7/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class HeatListCell: OEZTableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderColor = UIColor.white.cgColor
        iconImageView.layer.borderWidth = 1
        backView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setBackImage(imageName:String) {
        backImageView.image = UIImage(named: imageName)
    }
    override func update(_ data: Any!) {
        if  let model = data as? StarSortListModel {

            iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model.pic_tail), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            nameLabel.text = model.name
            priceLabel.text = model.currentPrice > 0 ? String(format: "%.2f", model.currentPrice) : ""
            jobLabel.text = model.work
            
        }
    }

}
