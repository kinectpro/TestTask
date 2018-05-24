//
//  AllertsManager.swift
//  TestTask
//
//  Created by Bobby numdevios on 23.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import Foundation
import UIKit

class AlertsManager: NSObject {
    static let shared = AlertsManager()
    func presentAlert(_ viewController:UIViewController, title:String,message:String ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true) {
            
        }
    }
}
