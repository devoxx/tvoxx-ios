//
//  Track.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 29/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit

class Track: NSObject {
    var trackId:String
    var title:String
    var talks:[TalkListItem]
    
    init(withTrackId trackId: String, title: String, talks: [TalkListItem]) {
        self.trackId = trackId
        self.title = title
        self.talks = talks
    }
    
    init(withDictionary dict:Dictionary<String, AnyObject>) {
        self.trackId = dict["trackId"] as! String
        self.title = dict["title"] as! String
        var talks = [TalkListItem]()
        if let talksArray = dict["talks"] as? [Dictionary<String, AnyObject>] {
            for talkDict in talksArray {
                talks.append(TalkListItem(withDictionary:talkDict))
            }
        }
        self.talks = talks
    }
}
