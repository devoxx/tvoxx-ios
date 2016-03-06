//
//  TalkDetail.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 06/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

class TalkDetail: NSObject {
    var talkId:String
    var talkType:String
    var title:String
    var summary:String
    var summaryAsHtml:String
    var trackTitle:String
    var lang:String
    var averageRating:Double?
    var numberOfRatings:Int?
    var youtubeVideoId:String
    var thumbnailUrl:String
    var conferenceLabel:String
    var speakers:[SpeakerListItem]
    var duration:String
    
    init(withDictionary dict:[String: AnyObject]) {
        self.talkId = dict["talkId"] as! String
        self.talkType = dict["talkType"] as! String
        self.title = dict["title"] as! String
        self.summary = dict["summary"] as! String
        self.summaryAsHtml = dict["summaryAsHtml"] as! String
        self.trackTitle = dict["trackTitle"] as! String
        self.lang = dict["lang"] as! String
        self.averageRating = dict["averageRating"] as? Double
        self.numberOfRatings = dict["numberOfRatings"] as? Int
        self.thumbnailUrl = dict["thumbnailUrl"] as! String
        self.youtubeVideoId = dict["youtubeVideoId"] as! String
        self.conferenceLabel = dict["conferenceLabel"] as! String
        self.duration = dict["duration"] as! String
        
        self.speakers = [SpeakerListItem]()
        if let speakers = dict["speakers"] as? [[String:AnyObject]] {
            for speaker in speakers {
                self.speakers.append(SpeakerListItem(withDictionary: speaker))
            }
        }
        self.averageRating = dict["averageRating"] as? Double
    }
}
