//
//  ProfileViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 3/11/21.
//

import UIKit
import CoreData
import PhotosUI

class ProfileViewController: UIViewController {
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!

    @IBOutlet weak var topUpBtn: UIButton!
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var editImage: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logoutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 50
        editImage.layer.cornerRadius = 25
        context = app.persistentContainer.viewContext
        checkExistingImage()
        updateImageBtn()
        logoutBtn.layer.cornerRadius = 6
        topUpBtn.layer.cornerRadius = 6
        username.text = currentUser!.username
        firstName.text = currentUser!.firstName
        lastName.text = currentUser!.lastName
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        credits.text = "Credits: \(currentUser!.credits.round(to: 2))"
    }
    @IBAction func topUp(_ sender: UIButton) {
        performSegue(withIdentifier: "topUp", sender: nil)
    }
    @IBAction func editImagePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        // access the camera
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            }
        }))
        // access the photo library
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
                self.checkExistingImage()
            }
        }))
        if profileImage.image != UIImage(named: "default") {
            // if user has no image, the delete image option will not apppear
            alert.addAction(UIAlertAction(title: "Delete Image", style: .destructive, handler: { _ in
                self.profileImage.image = UIImage(named: "default")
                self.updateImageBtn()
                do {
                    let data = try self.context.fetch(User.fetchRequest())
                    if data.count == 0 {
                        print("No users found.")
                    } else {
                        for user in data {
                            if user.username == currentUser!.username {
                                user.img = nil
                                self.app.saveContext()
                                
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    @IBAction func changePassword(_ sender: UIButton) {
        performSegue(withIdentifier: "changePassword", sender: nil)
    }
    @IBAction func logOutPressed(_ sender: UIButton) {
        // set the isLoggedIn status to false and log the user out.
        let alert = UIAlertController(title: "Log Out?", message: "Are you sure you wish to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            do {
                let data = try self.context.fetch(User.fetchRequest())
                if data.count == 0 {
                    print("No users found.")
                } else {
                    for user in data {
                        if user.username == currentUser?.username {
                            user.isLoggedIn = false
                            self.app.saveContext()
                            currentUser = nil
                            self.performSegue(withIdentifier: "toLogin", sender: nil)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }))
        present(alert, animated: true)
    }
    
    func updateImageBtn() {
        if profileImage.image == UIImage(named: "default") {
            editImage.setImage(UIImage(named: "addImage"), for: .normal)
        } else {
            editImage.setImage(UIImage(named: "editImage"), for: .normal)
        }
    }
    
    func checkExistingImage() {
        // check if user has any saved profile picture in the database.
        do {
            let fetch = try context.fetch(User.fetchRequest())
            if fetch.count == 0 {
                print("No users found.")
            } else {
                for user in fetch {
                    if user.username == currentUser!.username {
                        if user.img == nil {
                            profileImage.image = UIImage(named: "default")
                        } else {
                            profileImage.image = UIImage(data: user.img!)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // set the image to the one provided by the user and save the image to user in database
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        profileImage.image = image
        updateImageBtn()
        do {
            let data = try context.fetch(User.fetchRequest())
            if data.count == 0 {
                print("No users found.")
            } else {
                for user in data {
                    if user.username == currentUser!.username {
                        if let imageData = profileImage.image?.pngData() {
                            user.img = imageData
                            app.saveContext()
                        }
                        
                    }
                }
            }
        } catch {
            print(error)
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
