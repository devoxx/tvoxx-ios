//
//  Talk.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit

class Talk: NSObject {
    var title:String
    var thumbnailUrl:String
    var youtubeVideoId:String
    var speakerNames:[String]
    var averageRating:Double?
    
    init(withTitle title:String, thumbnailUrl: String, youtubeVideoId:String, speakerNames:[String], averageRating:Double?) {
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.youtubeVideoId = youtubeVideoId
        self.speakerNames = speakerNames
        self.averageRating = averageRating
    }
    
    init(withDictionary dict:Dictionary<String, AnyObject>) {
        self.title = dict["title"] as! String
        self.thumbnailUrl = dict["thumbnailUrl"] as! String
        self.youtubeVideoId = dict["youtubeVideoId"] as! String
        self.speakerNames = [String]()
        if let speakers = dict["speakerNames"] as? [String] {
            self.speakerNames = speakers
        }
        self.averageRating = dict["averageRating"] as? Double
    }
}
