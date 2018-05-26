//
//  AddItemViewController.swift
//  TestTask
//
//  Created by Bobby numdevios on 24.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit
import CoreLocation


class AddItemViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var hashtagTextField: UITextField!
    
    let cameraHandler = CameraHandler()
    var locationManager:CLLocationManager!
    var userLocation:CLLocation!
    var isSelectedPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSelectedPhoto = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(addPhotoTap))
        self.placeImageView.isUserInteractionEnabled = true
        self.placeImageView.addGestureRecognizer(tapGestureRecognizer)
        determineMyCurrentLocation()
    }

    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if isSelectedPhoto {
             saveImage()
        }else{
            AlertsManager.shared.presentAlert(self, title: "Warning", message: "Please add photo from camera or gallery")
        }
    }
    
    func saveImage(){
        determineMyCurrentLocation()
        if userLocation == nil {
            return
        }
        
        let item = ItemModel()
        item.descriptionItem = descriptionTextField.text
        item.hashtag = hashtagTextField.text
        item.image = UIImageJPEGRepresentation(placeImageView.image!, 0.5)
        item.longitude = userLocation.coordinate.longitude.description
        item.latitude = userLocation.coordinate.latitude.description
        
        NetworkManager.shared.saveImage(image: item, success: {
            debugPrint("Image successfully created")
            self.isSelectedPhoto = false
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            AlertsManager.shared.presentAlert(self, title: "Error", message: error)
        }
    }
    
    @objc func addPhotoTap (_ sender:UIView){
        self.isSelectedPhoto = true
        cameraHandler.startImagePicker(vc: self, getLocationPhoto: true)
        cameraHandler.imagePickedBlock = { (image) in
            self.placeImageView.contentMode = .scaleToFill
            self.placeImageView.image = image
        }
        cameraHandler.imageLocationBlock = { (location) in
            self.userLocation = location
        }
        cameraHandler.cancelBlock = { (isCancel) in
            self.isSelectedPhoto = !isCancel
        }
    }
    
    //MARK: - Location Methods
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
        AlertsManager.shared.presentAlert(self, title: "Location error!", message: "Please, allow location permissions and try again!")
    }
}
