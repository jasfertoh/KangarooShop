//
//  LoginViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 3/11/21.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = app.persistentContainer.viewContext
        
        checkLoginStatus()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // UI Code
        backBtn.setImage(UIImage(named: "arrow"), for: .normal)
        username.layer.borderWidth = 1
        username.layoutMargins.left = 20
        username.layer.cornerRadius = 6
        password.layer.borderWidth = 1
        password.layoutMargins.left = 20
        password.layer.cornerRadius = 6
        loginBtn.layer.cornerRadius = 6
        
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func registerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        checkFields()
    }
    
    func checkLoginStatus() {
        // check if user is logged in.
        do {
            let fetch = try context.fetch(User.fetchRequest())
            if fetch.count == 0 {
                print("No users found")
            } else {
                for user in fetch {
                    if user.isLoggedIn {
                        currentUser = UserData(username: user.username!, firstName: user.firstName!, lastName: user.lastName!, isLoggedIn: user.isLoggedIn, credits: user.credits)
                        performSegue(withIdentifier: "toMain", sender: nil)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func checkFields() {
        
        // check if the relevant fields are empty, if they are, prompt an alert, if not, authenticate the user.
        var message = ""
        if username.text!.isEmpty && password.text!.isEmpty {
            message = "Please do not leave any blanks."
        } else if username.text!.isEmpty {
            message = "Please enter your username."
        } else if password.text!.isEmpty {
            message = "Please enter your password."
        }
        
        if message == "" {
            authenticateUser()
        } else {
            alertNotif(title: "Error", message: message, action: "Ok")
        }
    }
    
    func authenticateUser() {
        // check if username and password exists in database, if it does, set the logged in status to true. if it does not exist, then prompt an alert
        do {
            let predicate = NSPredicate(format: "username = %@ AND password = %@", username.text!, password.text!)
            let fetchRequest = User.fetchRequest()
            fetchRequest.predicate = predicate
            let fetch = try context.fetch(fetchRequest)
            if fetch.count == 0 {
                alertNotif(title: "Error", message: "Wrong username/password.\nPlease try again.", action: "Try again")
            } else {
                for user in fetch {
                    user.isLoggedIn = true
                    app.saveContext()
                    currentUser = UserData(username: user.username!, firstName: user.firstName!, lastName: user.lastName!, isLoggedIn: user.isLoggedIn, credits: user.credits)
                }
                let alert = UIAlertController(title: "Success", message: "Redirecting you now...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
                let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(runAlert), userInfo: nil, repeats: true)
                
            }
        } catch {
            print(error)
        }
    }
    @objc func runAlert() {
            performSegue(withIdentifier: "toMain", sender: nil)
        }
}


extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
