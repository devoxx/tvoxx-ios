//
//  UIViewController+WatchListErrors.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

extension UIViewController {
    func showBackendError(rootCause:NSError) {
        print(rootCause.debugDescription)
        let alert = UIAlertController(title: NSLocalizedString("Error while adding this talk to your watchlist", comment: ""),
                                      message: NSLocalizedString("Unknown error. Please try again later.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAuthenticationError() {
        let alert = UIAlertController(title: NSLocalizedString("Error while adding this talk to your watchlist", comment: ""),
                                      message: NSLocalizedString("You need to sign in to your iCloud account in order to add talks to your watch list. On the Home screen, launch Settings, tap Accounts, then tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
