//
//  WatchlistViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WatchlistViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel:UILabel!
    private var talks = [TalkListItem]()
    private var selectedTalk:TalkListItem?
    private var tapGestureRecognizer:UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emptyLabel.text = NSLocalizedString("No talk in watchlist. To add some, go to individual talks and tap \"Add to watchlist\".", comment: "")
        self.emptyLabel.hidden = false
        self.loadingView.hidden = true
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WatchlistViewController.tapped(_:)))
        self.tapGestureRecognizer?.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    func tapped(sender:UITapGestureRecognizer) {
        if sender.state == .Ended {
            if let focusedCell = UIScreen.mainScreen().focusedView as? TalkCollectionViewCell {
                if let player = focusedCell.play() {
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.presentViewController(playerController, animated: true, completion: { () -> Void in
                        player.play()
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emptyLabel.hidden = true
        self.loadingView.hidden = false
        WatchList.sharedWatchList.moviesInWatchList { (talks:[TalkListItem]?, error:WatchListError?) in
            self.loadingView.hidden = true
            if let error = error {
                self.emptyLabel.hidden = false
                switch error {
                case .NotAuthenticated:
                    self.emptyLabel.text = NSLocalizedString("You need to sign in to your iCloud account in order to use the watchlist feature. On the Home screen, launch Settings, tap Accounts, then tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", comment: "")
                case .BackendError(let rootCause):
                    self.emptyLabel.text = NSLocalizedString("Impossible to load your watchlist", comment: "")
                    NSLog("CloudKit error: " + rootCause.debugDescription)
                }
            } else {
                if let talks = talks where talks.count > 0 {
                    self.talks = talks
                } else {
                    self.talks = [TalkListItem]()
                    self.emptyLabel.text = NSLocalizedString("No talk in watchlist. To add some, go to individual talks and tap \"Add to watchlist\"", comment:"")
                    self.emptyLabel.hidden = false
                }
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTalkDetail" {
            if let selectedTalk = self.selectedTalk, talkDetailViewController = segue.destinationViewController as? TalkDetailViewController {
                talkDetailViewController.talk = selectedTalk
            }
        }
    }
    

}

extension WatchlistViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.talks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let talkCell = collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath) as! TalkCollectionViewCell
        talkCell.talk = self.talks[indexPath.row]
        return talkCell
    }
}

extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedTalk = self.talks[indexPath.row]
        self.performSegueWithIdentifier("showTalkDetail", sender: self)
    }
}
