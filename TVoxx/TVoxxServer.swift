//
//  TVoxxServer.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import Alamofire

class TVoxxServer: NSObject {
    static var sharedServer = TVoxxServer()
    
    var host:String
    
    private override init() {
        self.host = NSBundle.mainBundle().objectForInfoDictionaryKey("TVOXX_SERVER") as! String
    }
    
    func getTalks(callback:([Talk] -> Void)) {
        Alamofire.request(.GET, "\(host)/talks.json?withVideo=true", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var talks = [Talk]()
                    for talkDict in JSON {
                        if let thumbnailUrl = talkDict["thumbnailUrl"] as? String {
                            talks.append(Talk(withTitle: talkDict["title"] as! String, thumbnailUrl: thumbnailUrl, youtubeVideoId:talkDict["youtubeVideoId"] as! String))
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(talks)
                    })
                }
        }
    }
    
    func getSpeakers(callback:([Speaker] -> Void)) {
        Alamofire.request(.GET, "\(host)/speakers.json", parameters: nil)
            .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var speakers = [Speaker]()
                    for speakerDict in JSON {
                            speakers.append(Speaker(withUuid: speakerDict["uuid"] as! String, firstName: speakerDict["firstName"] as! String, lastName: speakerDict["lastName"] as! String, avatarUrl: speakerDict["avatarUrl"] as? String))
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(speakers)
                    })
                }
        }
    }
    
    func getTracks(callback:([Track] -> Void)) {
        Alamofire.request(.GET, "\(host)/tracks.json", parameters: nil)
            .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var tracks = [Track]()
                    for trackDict in JSON {
                        tracks.append(Track(withDictionary: trackDict))
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(tracks)
                    })
                }
        }
    }
}
