//
//  RegisterViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 3/11/21.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = app.persistentContainer.viewContext
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // UI Code
        backBtn.setImage(UIImage(named: "arrow"), for: .normal)
        registerBtn.layer.cornerRadius = 6
        username.layer.cornerRadius = 6
        username.layer.borderWidth = 1
        firstName.layer.cornerRadius = 6
        firstName.layer.borderWidth = 1
        lastName.layer.cornerRadius = 6
        lastName.layer.borderWidth = 1
        password.layer.cornerRadius = 6
        password.layer.borderWidth = 1
        confirmPass.layer.cornerRadius = 6
        confirmPass.layer.borderWidth = 1
        
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toLoginFromReg", sender: nil)
    }
    @IBAction func registerPressed(_ sender: UIButton) {
        checkFields()
    }
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func registerUser() {
        // create new object in the User entity and set the values to the information provided.
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        user.username = username.text!
        user.password = password.text!
        user.firstName = firstName.text!
        user.lastName = lastName.text!
        user.isLoggedIn = true
        user.credits = 200
        
        app.saveContext()
        
        currentUser = UserData(username: username.text!, firstName: firstName.text!, lastName: lastName.text!, isLoggedIn: true, credits: 200)
        
        let alert = UIAlertController(title: "Success", message: "Redirecting you now...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(runAlert), userInfo: nil, repeats: true)
        
        
        
    }
    @objc func runAlert() {
        performSegue(withIdentifier: "toHome", sender: nil)
    }
    
    func checkFields() {
        // check if the relevant fields are empty, if they are, prompt an alert, else, proceed to register user into database
        var message = ""
        if username.text!.isEmpty && password.text!.isEmpty {
            message = "Please do not leave any blanks."
        } else if username.text!.isEmpty {
            message = "Please enter your username."
        } else if firstName.text!.isEmpty {
            message = "Please enter your first name."
        } else if lastName.text!.isEmpty {
            message = "Please enter your last name."
        } else if password.text!.isEmpty {
            message = "Please enter your password."
        } else if confirmPass.text!.isEmpty {
            message = "Please confirm your password."
        } else if password.text! != confirmPass.text! {
            message = "Passwords do not match!"
        }
        
        do {
            // check if user already exists in database
            let fetchRequest = User.fetchRequest()
            let predicate = NSPredicate(format: "username MATCHES %@", username.text!)
            fetchRequest.predicate = predicate
            let data = try context.fetch(fetchRequest)
            if data.count > 0 {
                message = "Username already exists. Please try another."
            }
        } catch {
            print(error)
        }
        
        if message == "" {
            registerUser()
        } else {
            alertNotif(title: "Error", message: message, action: "Ok")
        }
    }
    
}
