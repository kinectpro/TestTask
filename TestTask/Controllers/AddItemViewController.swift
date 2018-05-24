//
//  AddItemViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 24.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import CoreLocation
import AssetsLibrary

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var hashtagTextField: UITextField!
    let imagePicker:UIImagePickerController = UIImagePickerController()
    var locationManager:CLLocationManager!
    var userLocation:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(addPhotoTap))
        self.placeImageView.isUserInteractionEnabled = true
        self.placeImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        determineMyCurrentLocation()
        guard userLocation != nil else {return}
        var item = ItemModel()
        item.descriptionItem = descriptionTextField.text
        item.hashtag = hashtagTextField.text
        item.image = UIImageJPEGRepresentation(placeImageView.image!, 0.5)
        item.longitude = Float(userLocation.coordinate.longitude)
        item.latitude = Float(userLocation.coordinate.latitude)
        
        NetworkManager.shared.saveImage(image: item, success: {
            print("Success save image")
        }) { (error) in
            print("Error!!")
        }
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
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            placeImageView.contentMode = .scaleToFill
            placeImageView.image = pickedImage
        }
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        let library = ALAssetsLibrary()
        library.asset(for: url as URL!, resultBlock: { (asset) in
            if let location = asset?.value(forProperty: ALAssetPropertyLocation) as? CLLocation {
                self.userLocation = location
            }
        }, failureBlock: { (error) in
            print("Error!")
        })
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Location Methods
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
