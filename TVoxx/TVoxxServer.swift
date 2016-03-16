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
    
    func getTalks(callback:([TalkListItem] -> Void)) {
        Alamofire.request(.GET, "\(host)/talks.json?withVideo=true", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var talks = [TalkListItem]()
                    for talkDict in JSON {
                        if (talkDict["thumbnailUrl"] as? String) != nil {
                            talks.append(TalkListItem(withDictionary: talkDict))
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(talks)
                    })
                }
        }
    }
    
    func getTalkWithTalkId(talkId:String, callback:(TalkDetail->Void)) {
        Alamofire.request(.GET, "\(host)/talks/\(talkId).json")
            .responseJSON { (response:Response<AnyObject, NSError>) in
                if let JSON = response.result.value as? [String:AnyObject] {
                    let talk = TalkDetail(withDictionary: JSON)
                    dispatch_async(dispatch_get_main_queue(), { 
                        callback(talk)
                    })
                }
        }
    }
    
    func getSpeakerWithUuid(uuid:String, callback:(SpeakerDetail -> Void)) {
        Alamofire.request(.GET, "\(host)/speakers/\(uuid).json")
            .responseJSON{ (response:Response<AnyObject, NSError>) in
                if let JSON = response.result.value as? [String:AnyObject] {
                    let speaker = SpeakerDetail(withDictionary: JSON)
                    dispatch_async(dispatch_get_main_queue(), {
                        callback(speaker)
                    })
                }
        }
    }
    
    func getSpeakers(callback:([SpeakerListItem] -> Void)) {
        Alamofire.request(.GET, "\(host)/speakers.json", parameters: nil)
            .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var speakers = [SpeakerListItem]()
                    for speakerDict in JSON {
                        speakers.append(SpeakerListItem(withDictionary:speakerDict))
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
                } else {
                    print(response.debugDescription)
                }
        }
    }
    
    /*func getTopTalks() -> [TalkListItem] {
        let semaphore = dispatch_semaphore_create(0)
        var rsp: Response<AnyObject, NSError>!
        Alamofire.request(.GET, "\(host)/talks/top.json", parameters: ["withVideo":"true", "count":"10"]).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            rsp = response
            dispatch_semaphore_signal(semaphore);
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        if let JSON = rsp.result.value as? [Dictionary<String, AnyObject>] {
            var talks = [TalkListItem]()
            for talkDict in JSON {
                if (talkDict["thumbnailUrl"] as? String) != nil {
                    talks.append(TalkListItem(withDictionary: talkDict))
                }
            }
            return talks
        } else {
            return [TalkListItem]()
        }
    }*/
    
    func getTopTalks(callback:([TalkListItem]->Void)) {
        Alamofire.request(.GET, "\(host)/talks/top", parameters: ["withVideo":"true", "count":"10"]).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                var talks = [TalkListItem]()
                for talkDict in JSON {
                    if (talkDict["thumbnailUrl"] as? String) != nil {
                        talks.append(TalkListItem(withDictionary: talkDict))
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback(talks)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback([TalkListItem]())
                })
            }
        }
    }
}
