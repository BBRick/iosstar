//
//  AuctionTimeCell.swift
//  iOSStar
//
//  Created by J-bb on 17/6/20.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class AuctionTimeCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setTimeText(text:String) {
        
        if text == "回收未开始" {
            timeLabel.text = text
        } else {
            timeLabel.setAttributeText(text: "剩余回收时间: \(text)", firstFont: 16, secondFont: 16, firstColor: UIColor(hexString: "333333"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 8, length: text.length()))
        }
    }
}
