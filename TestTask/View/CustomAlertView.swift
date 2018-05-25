//
//  CustomAlertView.swift
//  TestTask
//
//  Created by Bobby numdevios on 25.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit

class CustomAlertView: UIView, Modal {
    var backgroundView = UIView()
    var dialogView = UIView()
    
    
    convenience init(image:UIImage) {
        self.init(frame: UIScreen.main.bounds)
        initialize(image: image)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialize(image:UIImage){
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
        
        let dialogViewWidth = frame.width-64
        
        let imageView = UIImageView()
        imageView.frame.origin = CGPoint(x: 8, y: 8)
        imageView.frame.size = CGSize(width: dialogViewWidth - 16 , height: dialogViewWidth - 16)
        imageView.image = image
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        dialogView.addSubview(imageView)
        
        let dialogViewHeight = imageView.frame.height + 16
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)
    }
    
    @objc func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
}
