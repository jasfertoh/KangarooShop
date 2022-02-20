//
//  DetailViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 4/11/21.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    var cart = [CartItems]()
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var atcBtn: UIButton!
    @IBOutlet weak var buyNowBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        context = app.persistentContainer.viewContext
        
        productImage.image = UIImage(named: currentItem!.productImage)
        productTitle.text = currentItem!.productTitle
        productPrice.text = "\(currentItem!.productPrice)"
        productDescription.text = currentItem!.productDescription
        atcBtn.layer.cornerRadius = 6
        atcBtn.layer.borderWidth = 1
        buyNowBtn.layer.cornerRadius = 6
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cart"), style: .plain, target: self, action: #selector(tappedCart))
    }
    
    @objc func tappedCart() {
        performSegue(withIdentifier: "goCart", sender: nil)
    }
    
    @IBAction func buyNowPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "buyNow", sender: nil)
    }
    @IBAction func addToCartPressed(_ sender: UIButton) {
        // add to cart button
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
                dismiss(animated: true, completion: nil)
            } else {
                cart = [CartItems]()
                let newItem = CartItems(title: currentItem!.productTitle, image: currentItem!.productImage, price: currentItem!.productPrice, description: currentItem!.productDescription,
                    quantity: 1)
                for item in data {
                    if item.cart == nil { // if user has no items in cart, add the new item into the cart and save to database
                        cart.append(newItem)
                        
                        let encoder = JSONEncoder()
                        
                        let encodedItem = try encoder.encode(cart)
                        
                        item.cart = encodedItem
                        
                        app.saveContext()
                    } else { // if user has items  in cart, fetch the items from the database, add new item into the array and save to database
                        
                        let decoder = JSONDecoder()
                        let encoder = JSONEncoder()
                        let decodedItem = try decoder.decode([CartItems].self, from: item.cart!)

                        cart = decodedItem
                        for cartItem in cart {
                            if cartItem.productTitle == newItem.productTitle {
                                print("exists")
                                cartItem.productQty += 1
                                let encodedItem = try encoder.encode(cart)

                                item.cart = encodedItem
                                app.saveContext()
                                alertNotif(title: "Success", message: "Successfully added \(currentItem!.productTitle) into cart.", action: "Ok")
                                return
                            }
                        }
                        cart.append(newItem)

                        let encodedItem = try encoder.encode(cart)

                        item.cart = encodedItem
                        app.saveContext()
                    }
                }
                
                alertNotif(title: "Success", message: "Successfully added \(currentItem!.productTitle) into cart.", action: "Ok")
            }
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buyNow" {
            let _ = segue.destination as! CheckOutViewController
            checkOutCart = [CartItems(title: currentItem!.productTitle, image: currentItem!.productImage, price: currentItem!.productPrice, description: currentItem!.productDescription, quantity: 1)]
        }
    }
    
}
