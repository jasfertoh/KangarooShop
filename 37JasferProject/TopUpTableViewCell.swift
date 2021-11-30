//
//  TopUpTableViewCell.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 10/11/21.
//

import UIKit

class TopUpTableViewCell: UITableViewCell {

    static let identifier = "TopUpTableViewCell"
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(date: Date, amount: Double) {
        dateLabel.text = date.shortDate
        amountLabel.text = "\(amount.round(to: 2))"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
