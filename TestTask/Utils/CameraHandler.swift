//
//  CameraHandler.swift
//  TestTask
//
//  Created by Bobby numdevios on 24.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import AssetsLibrary

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage) -> Void)?
    var imageLocationBlock:((CLLocation) -> Void)?
    var cancelBlock:((Bool) -> Void)?
    var isGetLocationPhoto = false
    
    func startImagePicker(vc: UIViewController, getLocationPhoto: Bool = false) {
        currentVC = vc
        isGetLocationPhoto = getLocationPhoto
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
                                    AlertsManager.shared.presentAlert(self.currentVC, title: "Error", message: "Access denied")
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
                                    AlertsManager.shared.presentAlert(self.currentVC, title: "Error", message: "Access denied")
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
                popoverController.sourceView = vc.view
                popoverController.sourceRect = vc.view.bounds
            }
            //show choosing picker
            currentVC.present(optionMenu, animated: true, completion: nil)
            
        }
    }
    
    func showImagePicker(_ sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        currentVC.present(imagePicker, animated: true, completion: nil)
    }
    
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.cancelBlock?(true)
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickedBlock?(image)
        }else{
            print("Something went wrong")
        }
        
        //Check location from image
        if isGetLocationPhoto {
            let url = info[UIImagePickerControllerReferenceURL] as! URL
            let library = ALAssetsLibrary()
            library.asset(for: url as URL!, resultBlock: { (asset) in
                if let location = asset?.value(forProperty: ALAssetPropertyLocation) as? CLLocation {
                    self.imageLocationBlock?(location)
                }
            }, failureBlock: { (error) in
                print("Error!")
            })
        }
        
        currentVC.dismiss(animated: true, completion: nil)
    } 
}
