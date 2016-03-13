//
//  SpeakerDetail.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 12/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

class SpeakerDetail: NSObject {
    var uuid:String
    var firstName:String
    var lastName:String
    var avatarUrl:String?
    var bio:String
    var bioAsHtml:String
    var company:String?
    var lang:String
    var blog:String?
    var twitter:String?
    var talks:[TalkListItem]
    
    init(withDictionary dict:[String: AnyObject]) {
        self.uuid = dict["uuid"] as! String
        self.firstName = dict["firstName"] as! String
        self.lastName = dict["lastName"] as! String
        self.avatarUrl = dict["avatarUrl"] as? String
        self.bio = dict["bio"] as! String
        self.bioAsHtml = dict["bioAsHtml"] as! String
        self.company = dict["company"] as? String
        self.lang = dict["lang"] as! String
        self.blog = dict["blog"] as? String
        self.twitter = dict["twitter"] as? String
        
        self.talks = [TalkListItem]()
        if let speakers = dict["talks"] as? [[String:AnyObject]] {
            for speaker in speakers {
                talks.append(TalkListItem(withDictionary: speaker))
            }
        }
    }
}
