//
//  Utils.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 08/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func formatDuration(seconds:Int) -> String {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds)
        var durationString = ""
        if h>0 {
            durationString += String.localizedStringWithFormat("%d", h) + NSLocalizedString(" h ", comment: "")
        }
        if m>0 {
            durationString += String.localizedStringWithFormat("%02d", m) + NSLocalizedString(" min ", comment: "")
        }
        durationString += String.localizedStringWithFormat("%02d", s) + NSLocalizedString(" s", comment: "")
        
        return durationString
    }
    
    private static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
