//
//  WalletViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 4/11/21.
//

import UIKit
import CoreData

class WalletViewController: UIViewController {
    var purchasedItems = [PurchaseHistory]()
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coinAmount: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = app.persistentContainer.viewContext
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Top Up", style: .plain, target: self, action: #selector(topUpTap))
        fetchPurchaseHistory()
        coinAmount.text = "\(currentUser!.credits.round(to: 2))"
        tableView.register(WalletTableViewCell.nib(), forCellReuseIdentifier: WalletTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        lastUpdated.text = "as at \(Date.now.shortTime)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastUpdated.text = "as at \(Date.now.shortTime)"
        fetchPurchaseHistory()
        coinAmount.text = "\(currentUser!.credits.round(to: 2))"
    }
    
    @objc func topUpTap() {
        performSegue(withIdentifier: "toTopUp", sender: nil)
    }
    
    func fetchPurchaseHistory() {
        // fetch the user's purchase history
        do {
            let fetchRequest = User.fetchRequest()
            let pred = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = pred
            do {
                let data = try context.fetch(fetchRequest)
                if data.count == 0 {
                    print("no records found.")
                } else {
                    for item in data {
                        if item.purchases == nil {
                            print("no purchase records found.")
                        } else {
                            let decoder = JSONDecoder()
                            let decodedItem = try decoder.decode([PurchaseHistory].self, from: item.purchases!)
                            purchasedItems = decodedItem
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WalletTableViewCell.identifier) as! WalletTableViewCell
        cell.configure(date: purchasedItems[indexPath.row].purchaseDate, title: purchasedItems[indexPath.row].productTitle, price: purchasedItems[indexPath.row].productPrice)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                                  timeStyle: DateFormatter.Style = .medium,
                               in timeZone : TimeZone = .current,
                                  locale   : Locale = .current) -> String {
            Formatter.date.locale = locale
            Formatter.date.timeZone = timeZone
            Formatter.date.dateStyle = dateStyle
            Formatter.date.timeStyle = timeStyle
            return Formatter.date.string(from: self)
        }
    var shortDateTime: String  { localizedDescription(dateStyle: .short,  timeStyle: .short) }
    var shortTime: String  { localizedDescription(dateStyle: .none,   timeStyle: .short) }
    var shortDate: String { localizedDescription(dateStyle: .short, timeStyle: .none) }
}
