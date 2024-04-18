//
//  WishListTableViewCell.swift
//  MyWishList
//
//  Created by imhs on 4/16/24.
//

import UIKit

class WishListTableViewCell: UITableViewCell {    
    @IBOutlet weak var productIdLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
