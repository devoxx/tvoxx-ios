//
//  UIViewController+WatchListErrors.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

extension UIViewController {
    func showBackendError(rootCause:NSError, title:String) {
        print(rootCause.debugDescription)
        let alert = UIAlertController(title: title,
                                      message: NSLocalizedString("Unknown error. Please try again later.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAuthenticationError(title:String) {
        let alert = UIAlertController(title: title,
                                      message: NSLocalizedString("You need to sign in to your iCloud account in order to use the watchlist feature. On the Home screen, launch Settings, tap Accounts, then tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
