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
        Alamofire.request(.GET, "\(host)/talks.json", parameters: nil)
            .responseJSON { response in
                if let JSON = response.result.value as? [Dictionary<String, AnyObject>] {
                    //print("JSON: \(JSON)")
                    var talks = [Talk]()
                    for talkDict in JSON {
                        if let thumbnailUrl = talkDict["thumbnailUrl"] as? String {
                            talks.append(Talk(withTitle: talkDict["title"] as! String, thumbnailUrl: thumbnailUrl, youtubeUrl:talkDict["youtubeUrl"] as! String))
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(talks)
                    })
                }
        }
    }
}
