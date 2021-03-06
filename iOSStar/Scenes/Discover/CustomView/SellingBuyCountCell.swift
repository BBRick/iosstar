//
//  SellingBuyCountCell.swift
//  iOSStar
//
//  Created by J-bb on 17/7/8.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class SellingBuyCountCell: SellingBaseCell {

    @IBOutlet weak var countTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func setPanicModel(model: PanicBuyInfoModel?) {
        guard model != nil else {
            return
        }
        
        countTextField.placeholder = "当前最多能购买\(model!.publish_last_time)秒"
    }
}
