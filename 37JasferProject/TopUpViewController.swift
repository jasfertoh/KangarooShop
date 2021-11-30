//
//  TopUpViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 9/11/21.
//

import UIKit
import CoreData

class TopUpViewController: UIViewController {
    
    var topUpList = [TopUp]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var amountLabel: UITextField!
    @IBOutlet weak var topUpBtn: UIButton!
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        context = app.persistentContainer.viewContext
        tableView.dataSource = self
        tableView.register(TopUpTableViewCell.nib(), forCellReuseIdentifier: TopUpTableViewCell.identifier)
        topUpBtn.layer.cornerRadius = 6
        fetchTopUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchTopUp()
    }
    
    @IBAction func topUpPressed(_ sender: UIButton) {
        checkField()
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
                print("user not found")
            } else {
                for item in data {
                    item.credits += Double(amountLabel.text!)!
                    let topUpAmount = TopUp(amt: Double(amountLabel.text!)!, date: Date.now)
                    if item.topups == nil { // check if there are any top ups in the past
                        topUpList.append(topUpAmount)
                        let encodedData = try JSONEncoder().encode(topUpList)
                        item.topups = encodedData
                    } else {
                        // if there are top ups in the past, fetch previous top up history from database and add in new top up record
                        let decodedData = try JSONDecoder().decode([TopUp].self, from: item.topups!)
                        topUpList = decodedData
                        topUpList.append(topUpAmount)
                        let encodedData = try JSONEncoder().encode(topUpList)
                        item.topups = encodedData
                        
                    }
                    currentUser!.credits = item.credits
                    app.saveContext()
                    // prompt an alert upon successful top up
                    alertNotif(title: "Success", message: "Top up successful. You now have \(item.credits.round(to: 2)) credits.", action: "Ok")
                    amountLabel.text = ""
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func fetchTopUp() {
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
                print("no users found")
            } else {
                for item in data {
                    if item.topups != nil {
                        let decodedData = try JSONDecoder().decode([TopUp].self, from: item.topups!)
                        topUpList = decodedData
                    }
                    
                }
                
            }
            
        } catch {
            print(error)
        }
    }
    
    func checkField() {
        var message = ""
        if amountLabel.text == "" {
            message = "Please enter an amount."
        } else if Double(amountLabel.text!) == nil {
            message = "Please enter a number"
        }
        
        if message != "" {
            alertNotif(title: "Error", message: message, action: "Ok")
            return
        }
    }
}
extension TopUpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topUpList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopUpTableViewCell.identifier, for: indexPath) as! TopUpTableViewCell
        cell.configure(date: topUpList[indexPath.row].date, amount: topUpList[indexPath.row].amount)
        return cell
    }
    
    
}

public class TopUp: NSObject, Codable {
    var amount: Double
    var date: Date
    
    init(amt: Double, date: Date) {
        self.amount = amt
        self.date = date
    }
}
