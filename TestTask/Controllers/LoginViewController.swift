//
//  LoginViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 23.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {



    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        NetworkManager.shared.signIn(email:email, password: password, success: {
            print("Success login")
        }) { errorMessage in
            AlertsManager.shared.presentAlert(self, title: "Fail", message: errorMessage)
        }
    }
}
