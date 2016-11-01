//
//  AboutViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 02/04/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        self.versionLabel.text = String.localizedStringWithFormat(NSLocalizedString("Version %@ (%@)", comment:""), version!, build!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
