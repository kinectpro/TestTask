//
//  SignUpViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 23.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit
import AlamofireImage
import Photos
import AVFoundation

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let imagePicker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        setup()
    }
    
    func setup() {
        if let avatarUrl = UserDefaults.standard.object(forKey: "avatar"){
            self.avatarImageView.af_setImage(withURL: URL(string:avatarUrl as! String)!)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(addPhotoTap))
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func addPhotoTap (_ sender:UIView){
        
        var available : Bool = false  //marker for available resourses
        let optionMenu = UIAlertController(title: nil, message: "Choose source", preferredStyle: .actionSheet)
        
        // condition for available PhotoLibrary
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)||(AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined) {
            available = true
            
            let photoFromGallery = UIAlertAction(title: "Photo Gallery", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                var markerForStatusPhotoLibraryAccess = true
                if (PHPhotoLibrary.authorizationStatus() == .notDetermined) {
                    markerForStatusPhotoLibraryAccess = false
                }
                if (PHPhotoLibrary.authorizationStatus() == .denied)||(PHPhotoLibrary.authorizationStatus() == .notDetermined) {
                    PHPhotoLibrary.requestAuthorization(
                        { status in
                            // User clicked ok
                            if (status == .authorized) {
                                self.showImagePicker(.photoLibrary)
                                // User clicked don't allow
                            } else {
                                if markerForStatusPhotoLibraryAccess {
                                    AlertsManager.shared.presentAlert(self, title: "Error", message: "Access denied")
                                }
                            }
                    })
                } else {
                    self.showImagePicker(.photoLibrary)
                }
            })
            optionMenu.addAction(photoFromGallery)
        }
        
        // condition for available Camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            available = true
            
            let photoFromCamera = UIAlertAction(title: "Camera", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                var markerForStatusPhotoCameraAccess = true
                if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined) {
                    markerForStatusPhotoCameraAccess = false
                }
                if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined)||(AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied) {
                    
                    AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                        { (photoCameraGranted: Bool) -> Void in
                            // User clicked ok
                            if (photoCameraGranted) {
                                self.showImagePicker(.camera)
                                // User clicked don't allow
                            } else {
                                if markerForStatusPhotoCameraAccess {
                                    AlertsManager.shared.presentAlert(self, title: "Error", message: "Access denied")
                                }
                            }
                    })
                }
                else {
                    self.showImagePicker(.camera)
                }
            })
            optionMenu.addAction(photoFromCamera)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        if available {
            optionMenu.addAction(cancelAction)
            
            // for ipad. Show choosing picker from button
            if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }
            //show choosing picker
            self.present(optionMenu, animated: true, completion: nil)
            
        }
    }
    
    
    func showImagePicker(_ sourceType: UIImagePickerControllerSourceType){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
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
        }) { (error) in
            AlertsManager.shared.presentAlert(self, title: "Registration error", message: error)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImageView.contentMode = .scaleToFill
            avatarImageView.image = pickedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
