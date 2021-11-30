//
//  ChangePassViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 4/11/21.
//

import UIKit
import CoreData

class ChangePassViewController: UIViewController {
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.layer.cornerRadius = 6
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        context = app.persistentContainer.viewContext
    }

    @IBAction func savePressed(_ sender: UIButton) {
        changePass()
    }
    
    func changePass() {
        checkTextFields() // check text fields
        // if text fields are successfully checked with no error, check if the user's current password is the same as the old password inputted, and check if the new password is the same as the confirm password.
        do {
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", currentUser!.username)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            if data.count == 0 {
            } else {
                for user in data {
                    if user.password != oldPassword.text! {
                        alertNotif(title: "Error", message: "Old password is incorrect.", action: "Ok")
                    } else if newPassword.text! != confirmPassword.text! {
                        alertNotif(title: "Error", message: "Passwords do not match.", action: "Ok")
                    } else {
                        user.password = newPassword.text!
                        app.saveContext()
                        alertNotif(title: "Success", message: "Successfully saved new password.", action: "Ok")
                        clearTextFields()
                    }
                    
                }
            }
        } catch {
            print(error)
        }
    }
    
    func checkTextFields() {
        // check if the relevant text fields are empty, if they are, prompt an alert
        var message = ""
        if oldPassword.text!.isEmpty && newPassword.text!.isEmpty && confirmPassword.text!.isEmpty {
            message = "Please do not leave any blanks."
        } else if oldPassword.text!.isEmpty {
            message = "Please enter your old password."
        } else if newPassword.text!.isEmpty {
            message = "Please enter your new password."
        } else if confirmPassword.text!.isEmpty {
            message = "Please confirm your password."
        }
        
        if message != "" {
            alertNotif(title: "Error", message: message, action: "Ok")
            return
        }
    }
    
    func clearTextFields() {
        oldPassword.text = ""
        newPassword.text = ""
        confirmPassword.text = ""
    }
}

extension UIViewController {
    func alertNotif(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        present(alert, animated: true)
    }
}
