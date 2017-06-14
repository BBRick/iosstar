//
//  DealMarketCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/23.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class DealMarketCell: UITableViewCell {
    @IBOutlet weak var changePercentLabel: UILabel!
    @IBOutlet weak var changePriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setRealTimeData(model:RealTimeModel?) {
        guard model != nil else {
            return
        }
        changePriceLabel.text = String(format: "%.2f", model!.change)
        priceLabel.text = String(format: "%.2f", model!.currentPrice)
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
