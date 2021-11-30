//
//  MainViewController.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 6/11/21.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loadingText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Code
        loadingText.text = "KNOWLEDGE\nIS\nPOWER."
        loginBtn.layer.cornerRadius = 6
        registerBtn.layer.cornerRadius = 6
        loginBtn.layer.borderWidth = 2
        registerBtn.layer.borderWidth = 2
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goLogin", sender: nil)
    }
    @IBAction func registerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goRegister", sender: nil)
    }
}

