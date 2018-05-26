//
//  ImagesCell.swift
//  TestTask
//
//  Created by Bobby numdevios on 25.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import UIKit
import AlamofireImage

class ImagesCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func update(imageModel:ImageModel){
        guard let urlString = imageModel.smallImagePath,
              let parameters = imageModel.parameters,
              let weather = parameters.weather else {return}
        
        itemImageView.af_setImage(withURL: URL(string:urlString)!)
        weatherLabel.text = weather
        
        let address = parameters.address ?? "No Address"
        addressLabel.text = address
    }
}
