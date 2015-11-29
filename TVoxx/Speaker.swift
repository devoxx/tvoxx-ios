//
//  Speaker.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 29/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit

class Speaker: NSObject {
    var uuid:String
    var firstName:String?
    var lastName:String?
    var avatarUrl:String?
    
    init(withUuid uuid:String, firstName:String, lastName:String, avatarUrl:String?) {
        self.uuid = uuid
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
    }
}
