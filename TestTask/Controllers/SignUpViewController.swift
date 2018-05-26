//
//  SignUpViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 23.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit
import AlamofireImage

class SignUpViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let cameraHandler = CameraHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.clipsToBounds = true
        if let avatarUrl = UserDefaults.standard.object(forKey: "avatar"){
            self.avatarImageView.af_setImage(withURL: URL(string:avatarUrl as! String)!)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(addPhotoTap))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func addPhotoTap (_ sender:UIView){
        
        cameraHandler.startImagePicker(vc: self)
        cameraHandler.imagePickedBlock = { (image) in
            self.avatarImageView.contentMode = .scaleToFill
            self.avatarImageView.image = image
        }
    }
    
    // MARK: - Actions
    @IBAction func sendTapped(_ sender: UIButton) {
        
        let username = userNameTextField.text
        let email = emailTextField.text
        let password = passwordTextField.text
        let imageData:Data?
        if let image = avatarImageView.image {
            imageData = UIImageJPEGRepresentation(image, 0.3)
        }else{
            imageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "user_logo"))
        }
        
        if username == "" || email == "" || password == "" {
            AlertsManager.shared.presentAlert(self, title: "Warning", message: "Fields should not be blank")
            return
        }
        
        NetworkManager.shared.register(username: username, email: email, password: password, avatar: imageData, success: {
            print("Success register !")
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
            self.navigationController!.pushViewController(controller, animated: true)
        }) { (error) in
            AlertsManager.shared.presentAlert(self, title: "Registration error", message: error)
        }
    }
}
