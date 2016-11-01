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
    
    fileprivate override init() {
        self.host = Bundle.main.object(forInfoDictionaryKey: "TVOXX_SERVER") as! String
    }
    
    func getTalks(_ callback:@escaping (([TalkListItem]) -> Void)) {
        Alamofire.request("\(host)/talks.json", parameters: ["withVideo":"true"])
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var talks = [TalkListItem]()
                    for talkDict in JSON {
                        if (talkDict["thumbnailUrl"] as? String) != nil {
                            talks.append(TalkListItem(withDictionary: talkDict))
                        }
                    }
                    callback(talks)
                }
        }
    }
    
    func getTalkWithTalkId(_ talkId:String, callback:@escaping ((TalkDetail)->Void)) {
        Alamofire.request("\(host)/talks/\(talkId)")
            .responseJSON { response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    let talk = TalkDetail(withDictionary: JSON)
                    callback(talk)
                }
        }
    }
    
    func getSpeakerWithUuid(_ uuid:String, callback:@escaping ((SpeakerDetail) -> Void)) {
        Alamofire.request("\(host)/speakers/\(uuid)")
            .responseJSON{ response in
                if let JSON = response.result.value as? [String:AnyObject] {
                    let speaker = SpeakerDetail(withDictionary: JSON)
                    callback(speaker)
                }
        }
    }
    
    func getSpeakers(_ callback:@escaping (([SpeakerListItem]) -> Void)) {
        Alamofire.request("\(host)/speakers", parameters: ["withVideo":"true"])
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var speakers = [SpeakerListItem]()
                    for speakerDict in JSON {
                        speakers.append(SpeakerListItem(withDictionary:speakerDict))
                    }
                    callback(speakers)
                }
        }
    }
    
    func getTracks(_ callback:@escaping (([Track]) -> Void)) {
        Alamofire.request("\(host)/tracks", parameters: ["withVideo":"true"])
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    var tracks = [Track]()
                    for trackDict in JSON {
                        tracks.append(Track(withDictionary: trackDict))
                    }
                    callback(tracks)
                } else {
                    print(response.debugDescription)
                }
        }
    }
    
    func getTopTalks(_ callback:@escaping (([TalkListItem])->Void)) {
        Alamofire.request("\(host)/talks/top", parameters: ["withVideo":"true", "count":"10"]).responseJSON { response in
            if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                var talks = [TalkListItem]()
                for talkDict in JSON {
                    if (talkDict["thumbnailUrl"] as? String) != nil {
                        talks.append(TalkListItem(withDictionary: talkDict))
                    }
                }
                callback(talks)
            } else {
                callback([TalkListItem]())
            }
        }
    }
    
    func searchForText(_ text:String, callback:@escaping (([TalkListItem]) -> Void)) {
        Alamofire.request("\(host)/talks/search", parameters: ["withVideo":"true", "q":text]).responseJSON { response in
            if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                var talks = [TalkListItem]()
                for talkDict in JSON {
                    if (talkDict["thumbnailUrl"] as? String) != nil {
                        talks.append(TalkListItem(withDictionary: talkDict))
                    }
                }
                callback(talks)
            } else {
                callback([TalkListItem]())
            }
        }
    }
}
