//
//  EditAddressViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit
import CoreData

class EditAddressViewController: UIViewController {
    var addressList = [Address]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAddressBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = app.persistentContainer.viewContext
        tableView.register(AddressTableViewCell.nib(), forCellReuseIdentifier: AddressTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        addAddressBtn.layer.cornerRadius = 6
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchAddress()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func fetchAddress() {
        // fetch all the addresses belonging to the user from the database
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("No users found")
            } else {
                for item in data {
                    if item.address == nil {
                        print("No addresses found")
                    } else {
                        let decoder = JSONDecoder()
                        let decodedItem = try decoder.decode([Address].self, from: item.address!)
                        addressList = decodedItem
                        for i in 0..<addressList.count {
                            for (key, value) in addressList[i].addressList {
                                print(key, value)
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    @IBAction func addAddress(_ sender: Any) {
        performSegue(withIdentifier: "addAddress", sender: nil)
    }
    
}

extension EditAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell") as! AddressTableViewCell
        for (address, val) in addressList[indexPath.row].addressList {
            cell.configure(address: address, main: val)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // if user selects the row, set the selected address in that row to default address
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("no users found")
            } else {
                for item in data {
                    let decodedItem = try JSONDecoder().decode([Address].self, from: item.address!)
                    for address in decodedItem { // [String: Bool]
                        for (add, main) in address.addressList {
                            if main {
                                address.addressList[add] = false
                                print(address.addressList[add])
                                
                            }
                        }
                    }
                    
                    for (add, main) in decodedItem[indexPath.row].addressList {
                        decodedItem[indexPath.row].addressList[add] = true
                        
                    }
                    
                    
                    let encodedItem = try JSONEncoder().encode(decodedItem)
                    item.address = encodedItem
                    app.saveContext()
                }
            }
        } catch {
            print(error)
        }
        fetchAddress()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // if user chooses to delete the row
        if editingStyle == .delete {
            addressList.remove(at: indexPath.row)
            do {
                let fetchRequest = User.fetchRequest()
                let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
                fetchRequest.predicate = pred
                let data = try context.fetch(fetchRequest)
                
                if data.count == 0 {
                    print("No users found")
                } else {
                    for item in data {
                        let encodedItem = try JSONEncoder().encode(addressList)
                        item.address = encodedItem
                        app.saveContext()
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    
                }
            } catch {
                print(error)
            }
            
            
            
        }
    }
    
}
