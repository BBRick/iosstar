//
//  DealMarketCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/23.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class DealMarketCell: UITableViewCell {
//    @IBOutlet weak var changePercentLabel: UILabel!
//    @IBOutlet weak var changePriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.textColor = UIColor.init(hexString: AppConst.Color.orange)
//        changePriceLabel.textColor = UIColor.init(hexString: AppConst.Color.up)
//        changePercentLabel.textColor = UIColor.init(hexString: AppConst.Color.up)
        
        // Initialization code
    }


    
    func setRealTimeData(model:RealTimeModel?) {
        guard model != nil else {
            return
        }
//        var colorString = AppConst.Color.up
//        let percent = model!.pchg * 100

//        if model!.pchg < 0 {
//            changePercentLabel.text = String(format: "%.2f%%", -percent)
//            changePriceLabel.text = String(format: "%.2f", model!.change)
//            colorString = AppConst.Color.down
//        } else if model!.pchg == 0{
//            changePercentLabel.text = String(format: "%.2f%%", -percent)
//            
//            changePriceLabel.text = String(format: "%.2f", model!.change)
//            colorString = "333333"
//        } else {
//            changePercentLabel.text = String(format: "+%.2f%%",percent)
//
//            changePriceLabel.text = String(format: "%.2f",model!.change)
//        }
//        changePriceLabel.textColor = UIColor(hexString: colorString)
//        changePercentLabel.textColor = UIColor(hexString: colorString)


        priceLabel.text = String(format: "%.2f", model!.currentPrice)
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
