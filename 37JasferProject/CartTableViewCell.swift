//
//  CartTableViewCell.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    
    static let identifier = "CartTableViewCell"

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with image: String, title: String, price: Double) {
        productTitle.text = title
        productImage.image = UIImage(named: image)
        productPrice.text = "\(price.round(to: 2))0"
    }

    static func nib() -> UINib {
        return UINib(nibName: "CartTableViewCell", bundle: nil)
    }

}
