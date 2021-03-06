//
//  SellingIntroCell.swift
//  iOSStar
//
//  Created by J-bb on 17/7/8.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class SellingIntroCell: SellingBaseCell {

    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backImageView.contentMode = .scaleAspectFill
        backImageView.clipsToBounds = true
     }

    override func setPanicModel(model: PanicBuyInfoModel?) {
        guard model != nil else {
            return
        }
        nickNameLabel.text = model?.star_name
        backImageView.kf.setImage(with: URL(string: model!.back_pic_url), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        iconImageView.kf.setImage(with: URL(string: model!.head_url), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
