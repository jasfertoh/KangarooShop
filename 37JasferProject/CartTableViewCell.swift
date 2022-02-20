//
//  CartTableViewCell.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit
import CoreData

protocol CartDelegate {
   func cartUpdate()
}

class CartTableViewCell: UITableViewCell {
    
    static let identifier = "CartTableViewCell"

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var itemPrice = 0.00
    var cartItem: CartItems!
    var cartItems = [CartItems]()
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var delegate: CartDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        context = app.persistentContainer.viewContext
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with image: String, title: String, price: Double, quantity: Int) {
        productTitle.text = title
        productImage.image = UIImage(named: image)
        productQty.text = String(quantity)
        productPrice.text = "\(Double(quantity) * price.round(to: 2))0"
        itemPrice = price
    }
    
    @IBAction func qtyStepper(_ sender: UIStepper) {
        stepper.minimumValue = 1
        productQty.text = String(Int(sender.value))
        productPrice.text = "\(sender.value * itemPrice.round(to: 2))0"
        cartItem.productQty = Int(sender.value)
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let fetchRequest = User.fetchRequest()
        let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
        fetchRequest.predicate = pred
        do {
            let data = try context.fetch(fetchRequest)
            if data.count != 0 {
                for item in data {
                    let decodedItem = try decoder.decode([CartItems].self, from: item.cart!)
                    cartItems = decodedItem
                    for i in cartItems {
                        if i.productTitle == cartItem.productTitle {
                            i.productQty = cartItem.productQty
                            let encodedItem = try encoder.encode(cartItems)
                            item.cart = encodedItem
                            app.saveContext()
                            self.delegate?.cartUpdate()
                            return
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        
    }

    static func nib() -> UINib {
        return UINib(nibName: "CartTableViewCell", bundle: nil)
    }

}
