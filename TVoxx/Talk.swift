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
    
    init(withTitle title:String, thumbnailUrl: String, youtubeVideoId:String) {
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.youtubeVideoId = youtubeVideoId
    }
    
    init(withDictionary dict:Dictionary<String, AnyObject>) {
        self.title = dict["title"] as! String
        self.thumbnailUrl = dict["thumbnailUrl"] as! String
        self.youtubeVideoId = dict["youtubeVideoId"] as! String
    }
}
