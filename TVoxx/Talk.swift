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
    var youtubeUrl:String
    
    init(withTitle title:String, thumbnailUrl: String, youtubeUrl:String) {
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.youtubeUrl = youtubeUrl
    }
}
