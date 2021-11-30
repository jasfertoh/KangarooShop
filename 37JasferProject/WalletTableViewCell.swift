//
//  WalletTableViewCell.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit

class WalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    static var identifier = "WalletTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(date: Date, title: String, price: Double) {
        dateLabel.text = "\(date.shortDate)"
        titleLabel.text = title
        priceLabel.text = "\(price)0"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
