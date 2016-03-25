//
//  Talk.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import CloudKit

class TalkListItem: NSObject {
    var talkId:String
    var title:String
    var summary:String
    var trackTitle:String?
    var thumbnailUrl:String
    var youtubeVideoId:String
    var speakerNames:[String]
    var averageRating:Double?
    
    init(withDictionary dict:[String:AnyObject]) {
        self.summary = dict["summary"] as! String
        self.trackTitle = dict["trackTitle"] as? String
        self.talkId = dict["talkId"] as! String
        self.title = dict["title"] as! String
        self.thumbnailUrl = dict["thumbnailUrl"] as! String
        self.youtubeVideoId = dict["youtubeVideoId"] as! String
        self.speakerNames = [String]()
        if let speakers = dict["speakerNames"] as? [String] {
            self.speakerNames = speakers
        }
        self.averageRating = dict["averageRating"] as? Double
    }
    
    init(withRecord record:CKRecord){
        self.summary = record["summary"] as! String
        self.talkId = record["talkId"] as! String
        self.title = record["title"] as! String
        self.trackTitle = record["trackTitle"] as? String
        self.thumbnailUrl = record["thumbnailUrl"] as! String
        self.youtubeVideoId = record["youtubeVideoId"] as! String
        self.speakerNames = [String]()
        self.averageRating = (record["averageRating"] as! NSNumber).doubleValue
    }
}
