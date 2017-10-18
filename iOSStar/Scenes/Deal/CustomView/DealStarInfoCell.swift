//
//  DealStarInfoCell.swift
//  iOSStar
//
//  Created by J-bb on 17/5/23.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit


class DealStarInfoCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    var delegate:ShowEntrustDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        // Initialization code
    }
    @IBAction func showEntrust(_ sender: Any) {
        delegate?.show()
    }

    
    func setupData(model:StarSortListModel?) {
        guard  model != nil else {
            return
        }

        iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model!.pic_tail))
        nameLabel.text = model?.name


    }
    
    func setCount(count:Int) {
    
        let text = "当前总持有\(count)秒"
        positionLabel.setAttributeText(text:text,firstFont:14, secondFont:20, firstColor:UIColor(hexString:"333333"), secondColor:UIColor(hexString:"FB9938"), range:NSRange(location: 5, length: text.length() - 6))
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
