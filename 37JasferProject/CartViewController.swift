//
//  CartViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit
import CoreData

var checkOutCart = [CartItems]()

class CartViewController: UIViewController, CartDelegate {
    var cartItems = [CartItems]()
    var totalAmount = Double(0)
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!

    @IBOutlet weak var subtotal: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkOutBtn: UIButton!
    @IBOutlet weak var itemList: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CartTableViewCell.nib(), forCellReuseIdentifier: CartTableViewCell.identifier)
        context = app.persistentContainer.viewContext
        fetchSubtotal()
        tableView.dataSource = self
        tableView.delegate = self
        checkOutBtn.layer.cornerRadius = 6
        fetchItemsInCart()
    }
    
    func fetchSubtotal() {
        // fetch the subtotal by adding the price of all the items in the cart.
        do {
            totalAmount = 0.0
            let decoder = JSONDecoder()
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
                print("no users found")
            } else {
                for item in data {
                    
                    if item.cart == nil {
                        print("no items in carts")
                    } else {
                        let decodedItem = try decoder.decode([CartItems].self, from: item.cart!)
                        cartItems = decodedItem
                        for i in decodedItem {
                            totalAmount += (i.productPrice * Double(i.productQty))
                        }
                    }
                    
                }
            }
            subtotal.text = "\(totalAmount)0 credits"
        } catch {
            print(error)
        }
    }
    
    func cartUpdate() {
        fetchSubtotal()
    }
    
    @IBAction func checkOutPressed(_ sender: UIButton) {
        // check if the cart is empty when attempting to check out
        let decoder = JSONDecoder()
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
                print("no users found")
            } else {
                for item in data {
                    if item.cart == nil {
                        alertNotif(title: "Error", message: "You need to add items in your cart first!", action: "Ok")
                    } else {
                        let decodedItem = try decoder.decode([CartItems].self, from: item.cart!)
                        checkOutCart = decodedItem
                    }
                    
                }
                performSegue(withIdentifier: "toCheckout", sender: nil)
            }
            
        } catch {
            print(error)
        }
    }
    
    func fetchItemsInCart() {
        // fetch the existing items in the user's cart.
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            let cart = try context.fetch(fetchRequest)
            if cart.count == 0 {
                print("No cart items found.")
            } else {
                cartItems = [CartItems]()
                for user in cart {
                    if user.cart == nil {
                        print("no items in cart")
                        itemList.text = "\(cartItems.count) ITEMS"
                    } else {
                        let decoder = JSONDecoder()
                        let decodedItem = try decoder.decode([CartItems].self, from: user.cart!)
                        cartItems = decodedItem
                        itemList.text = "\(cartItems.count) ITEMS"
                    }
                    
                }
            }
            
            
        } catch {
            print(error)
        }
    }

}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier) as! CartTableViewCell
        cell.configure(with: cartItems[indexPath.row].productImage, title: cartItems[indexPath.row].productTitle, price: cartItems[indexPath.row].productPrice, quantity: cartItems[indexPath.row].productQty)
        cell.stepper.value = Double(cartItems[indexPath.row].productQty)
        cell.cartItem = cartItems[indexPath.row]
        cell.delegate = self
        cell.delegate?.cartUpdate()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        currentItem = ItemData(productTitle: cartItems[indexPath.row].productTitle, productImage: cartItems[indexPath.row].productImage, productPrice: cartItems[indexPath.row].productPrice, productDescription: cartItems[indexPath.row].productDescription)
        performSegue(withIdentifier: "toItem", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if user removes an item from the cart, delete the item's amount from the subtotal amount.
        if editingStyle == .delete {
            totalAmount -= (cartItems[indexPath.row].productPrice * Double(cartItems[indexPath.row].productQty))
            subtotal.text = "\(totalAmount)0 credits"
            
            cartItems.remove(at: indexPath.row)
            itemList.text = "\(cartItems.count) ITEMS"
            do {
                let encoder = JSONEncoder()
                let encodedItem = try encoder.encode(cartItems)
                let fetchRequest = User.fetchRequest()
                let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
                fetchRequest.predicate = pred
                let data = try context.fetch(fetchRequest)
                if data.count == 0 {
                    print("user does not exist.")
                } else {
                    for item in data {
                        item.cart = encodedItem
                        app.saveContext()
                    }
                }
            } catch {
                print(error)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
}

