//
//  ItemModel.swift
//  TestTask
//
//  Created by MacBook on 5/24/18.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import Foundation
import ObjectMapper

class ItemModel:NSObject, Mappable {
    var image:Data?
    var descriptionItem: String?
    var hashtag:String?
    var latitude:Float?
    var longitude:Float?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        image         <- map["image"]
        descriptionItem  <- map["description"]
        hashtag  <- map["hashtag"]
        latitude  <- map["latitude"]
        longitude  <- map["longitude"]
    }
}
