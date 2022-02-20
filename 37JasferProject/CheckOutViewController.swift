//
//  CheckOutViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit
import CoreData

class CheckOutViewController: UIViewController {
    var shook = false
    var totalAmount = Double(0)
    var purchasedItems = [PurchaseHistory]()
    var addressList = [Address]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var discount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        context = app.persistentContainer.viewContext
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CartTableViewCell.nib(), forCellReuseIdentifier: CartTableViewCell.identifier)
        for item in checkOutCart {
            totalAmount += (Double(item.productPrice) * Double(item.productQty))
        }
        
        confirmBtn.layer.cornerRadius = 6
        checkUserAddress()
        print(totalAmount)
        total.text = "\(totalAmount)0 credits"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUserAddress()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            calculateRandomDiscount()
        }
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editAddress", sender: nil)
    }
    @IBAction func placeOrderPressed(_ sender: UIButton) {
        if addressLabel.text == "Default address has not been set." {
            alertNotif(title: "Error", message: "Default address has not been set.", action: "Ok")
            return
        } else if !shook {
            alertNotif(title: "Error", message: "You have to shake for a discount!", action: "Ok")
            return
        }
        if Double(currentUser!.credits) >= totalAmount {
            // check if user's credits are sufficient for the purchase.
            do {
                let fetchRequest = User.fetchRequest()
                let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
                fetchRequest.predicate = pred
                let data = try context.fetch(fetchRequest)
                if data.count == 0 {
                    print("user cannot be found")
                } else {
                    for item in data {
                        if item.address == nil {
                            alertNotif(title: "Error", message: "You do not have an address set!", action: "Ok")
                        } else {
                            currentUser!.credits -= Double(totalAmount)
                            item.credits = currentUser!.credits
                            item.cart = nil
                            if item.purchases == nil {
                                for item in checkOutCart {
                                    let purchase = PurchaseHistory(title: item.productTitle, price: totalAmount , date: Date.now)
                                    purchasedItems.append(purchase)
                                }
                            } else {
                                let decodedItem = try JSONDecoder().decode([PurchaseHistory].self, from: item.purchases!)
                                purchasedItems = decodedItem
                                for item in checkOutCart {
                                    let purchase = PurchaseHistory(title: item.productTitle, price: totalAmount.round(to: 2), date: Date.now)
                                    purchasedItems.append(purchase)
                                }
                            }
                            let encoder = JSONEncoder()
                            let encodedItem = try encoder.encode(purchasedItems)
                            item.purchases = encodedItem
                            app.saveContext()
                            let alert = UIAlertController(title: "Success", message: "Successfully placed an order.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                self.performSegue(withIdentifier: "orderConfirmed", sender: nil)
                            }))
                            present(alert, animated: true)
                        }
                        
                        
                    }
                }
            } catch {
                print(error)
            }
        } else {
            alertNotif(title: "Error", message: "You have insufficient credits.", action: "Ok")
        }
    }
    
    func checkUserAddress() {
        // fetch addresses belonging to the user, if there are none, set the text to address not added yet.
        // if there are addresses belonging to the user but there are no default address set, set the text to default address has not been set.
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("No user found.")
            } else {
                
                for item in data {
                    if item.address == nil {
                        addressLabel.text = "Address not added yet."
                    } else {
                        let decoder = JSONDecoder()
                        let decodedItem = try decoder.decode([Address].self, from: item.address!)
                        addressList = decodedItem
                        for address in addressList {
                            for (key, value) in address.addressList {
                                if value {
                                    addressLabel.text = "\(key)"
                                    break;
                                } else {
                                    addressLabel.text = "Default address has not been set."
                                }
                            }
                        }
                    }
                
                }
            }
        } catch {
            print(error)
        }
    }
    
    func calculateRandomDiscount() {
        // calculate random discount
        if shook { // if user shook the device already
            alertNotif(title: "Error", message: "You can only shake once!", action: "Ok")
        } else { // if user hasn't shook the device, calculate the discount and update the label text.
            let random = 0...20
            let chosen = random.randomElement()
            let disc = totalAmount * Double(Int(chosen!)) / 100.0
            let discPercentage = Double(Int(chosen!))
            alertNotif(title: "Success", message: "You received a discount of \(discPercentage)%.", action: "Ok")
            discount.text = "\(disc)0 credits"
            totalAmount -= Double(disc)
            total.text = "\(totalAmount)0 credits"
            shook = true
        }
        
    }
    
}

extension CheckOutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkOutCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell") as! CartTableViewCell
        cell.configure(with: checkOutCart[indexPath.row].productImage, title: checkOutCart[indexPath.row].productTitle, price: checkOutCart[indexPath.row].productPrice, quantity: checkOutCart[indexPath.row].productQty)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
