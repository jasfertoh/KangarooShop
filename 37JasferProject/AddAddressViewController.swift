//
//  AddAddressViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import UIKit
import CoreData

class AddAddressViewController: UIViewController {
    var addressList = [Address]()
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var errorStatus = false

    @IBOutlet weak var addressField: TextField!
    @IBOutlet weak var unitNo: TextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var postalCode: TextField!
    @IBOutlet weak var saveDefault: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        addressField.layer.cornerRadius = 6
        addressField.layer.borderWidth = 1
        unitNo.layer.cornerRadius = 6
        unitNo.layer.borderWidth = 1
        postalCode.layer.cornerRadius = 6
        postalCode.layer.borderWidth = 1
        context = app.persistentContainer.viewContext
        saveBtn.layer.cornerRadius = 6
    }
    
    
    @IBAction func savePressed(_ sender: UIButton) {
        updateAddress()
    }
    
    func checkFields() {
        // check if the relevant text fields are empty, if they are, prompt an alert.
        var message = ""
        if addressField.text == "" && unitNo.text == "" && postalCode.text == "" {
            message = "Please do not leave any blanks."
        } else if addressField.text == "" {
            message = "Please enter your address."
        } else if unitNo.text == "" {
            message = "Please enter your unit number."
        } else if postalCode.text == "" {
            message = "Please enter your postal code."
        } else if Int(postalCode.text!) == nil {
            message = "Postal code accepts only numbers!"
        }
        verifyPostalCode()
        if errorStatus {
            message = "Please enter a valid postal code."
        }
        if message != ""{
            alertNotif(title: "Error", message: message, action: "Ok")
            errorStatus = false
            return
        }
    }
    
    func verifyPostalCode() {
        // run the api to convert the postal code provided to coordinates
        let code = postalCode.text!
        let oneMapURL = URL(string: "https://developers.onemap.sg/commonapi/search?searchVal=\(code)&returnGeom=Y&getAddrDetails=Y&pageNum=1")
        guard let url = oneMapURL else {
            errorStatus = true
            return
        }
        print(url)
        let firstTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            var result: OneMapData?
            do {
                result = try JSONDecoder().decode(OneMapData.self, from: data)
            } catch {
                print(error)
            }
            
            guard let json = result else {
                print("error!")
                return
            }
            if json.found == 0 {
                self.errorStatus = true
            }
            
        }
        
        firstTask.resume()
    }
    
    func setNewDefault() {
        // set new default address
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("Error")
            } else {
                for item in data {
                    let decodedItem = try JSONDecoder().decode([Address].self, from: item.address!)
                    for address in decodedItem { // [String: Bool]
                        for (add, main) in address.addressList {
                            if main {
                                address.addressList[add] = false
                                
                            }
                        }
                    }
                    
                    let encodedItem = try JSONEncoder().encode(decodedItem)
                    item.address = encodedItem
                    app.saveContext()
                }
            }
        } catch {
            print("error")
        }
    }
    
    func updateAddress() {
        // update address to the new values provided
        checkFields()
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            let data = try context.fetch(fetchRequest)
            
            if data.count == 0 {
                print("user not found")
            } else {
                for item in data {
                    if item.address == nil {
                        let fullAddress = "\(addressField.text!)\n\(unitNo.text!)\nSingapore \(postalCode.text!)"
                        let newAddress = Address(add: fullAddress, mainAddress: true)
                        let encoder = JSONEncoder()
                        let encodedItem = try encoder.encode([newAddress])
                        item.address = encodedItem
                        app.saveContext()
                    } else {
                        var isMain = false
                        if saveDefault.isOn {
                            setNewDefault()
                            isMain = true
                        }
                        let decoder = JSONDecoder()
                        let decodedItem = try decoder.decode([Address].self, from: item.address!)
                        addressList = decodedItem
                        let fullAddress = "\(addressField.text!)\n\(unitNo.text!)\nSingapore \(postalCode.text!)"
                        let newAddress = Address(add: fullAddress, mainAddress: isMain)
                        addressList.append(newAddress)
                        let encoder = JSONEncoder()
                        let encodedItem = try encoder.encode(addressList)
                        item.address = encodedItem
                        app.saveContext()
                    }
                    
                    let alert = UIAlertController(title: "Success", message: "Successfully saved the address.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.unitNo.text = ""
                        self.postalCode.text = ""
                        self.addressField.text = ""
                    }))
                    present(alert, animated: true)
                }
            }
        } catch {
            print(error)
        }
    }
    

}
