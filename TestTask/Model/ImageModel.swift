//
//  ImageModel.swift
//  TestTask
//
//  Created by Bobby numdevios on 25.05.2018.
//  Copyright © 2018 kinectpro. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageModel:NSObject, Mappable {
    var id:Int?
    var descriptionItem: String?
    var hashtag:String?
    var parameters:Parameters?
    var smallImagePath:String?
    var bigImagePath:String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id               <- map["id"]
        descriptionItem  <- map["description"]
        hashtag          <- map["hashtag"]
        parameters       <- map["parameters"]
        smallImagePath   <- map["smallImagePath"]
        bigImagePath     <- map["bigImagePath"]
    }
}

class Parameters:NSObject, Mappable {
    var longitude:Float?
    var latitude: Float?
    var weather:String?
    var address:String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        longitude  <- map["longitude"]
        latitude   <- map["latitude"]
        weather    <- map["weather"]
        address    <- map["address"]
    }
}

