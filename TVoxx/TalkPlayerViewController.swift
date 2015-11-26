//
//  TalkPlayerViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 26/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TalkPlayerViewController: AVPlayerViewController {
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        self.player?.play()
    }
}
