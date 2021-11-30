//
//  AddressTableViewCell.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    static let identifier = "AddressTableViewCell"
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var isMainAddressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(address: String, main: Bool) {
        addressLabel.text = address
        if main {
            isMainAddressLabel.isHidden = false
        } else {
            isMainAddressLabel.isHidden = true
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
}
