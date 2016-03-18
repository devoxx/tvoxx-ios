//
//  FirstViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 20/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TracksViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var tracks = [Track]()
    private var selectedTalk: TalkListItem?
    private var tapGestureRecognizer: UIGestureRecognizer?
    
    private var selectionObserver:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
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
        
        self.collectionView.hidden = true
        self.loadingIndicator.startAnimating()
        self.loadingView.hidden = false
        
        TVoxxServer.sharedServer.getTracks { (tracks:[Track]) -> Void in
            if tracks.count == 0 {
                self.loadingLabel.text = NSLocalizedString("No talk to load", comment:"")
                self.loadingIndicator.hidden = true
                self.loadingView.hidden = false
            } else {
                self.loadingView.hidden = true
                self.tracks = tracks
                self.collectionView.reloadData()
                self.collectionView.hidden = false
            }
        }
        
        self.selectionObserver = NSNotificationCenter.defaultCenter().addObserverForName("talkSelected", object: nil, queue: NSOperationQueue.mainQueue()) { (notification:NSNotification) -> Void in
            self.selectedTalk = notification.userInfo!["selectedTalk"] as? TalkListItem
            self.performSegueWithIdentifier("showTalkDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destinationViewController as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let selectionObserver = self.selectionObserver {
            NSNotificationCenter.defaultCenter().removeObserver(selectionObserver)
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TracksViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.tracks.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TrackCell", forIndexPath: indexPath) as! TrackCollectionViewCell
        cell.track = self.tracks[indexPath.section]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TrackHeader", forIndexPath: indexPath) as! TrackCollectionReusableView
            headerView.titleLabel.text = self.tracks[indexPath.section].title
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
    
    func openTalkWithTalkId(talkId:String, play:Bool) {
        TVoxxServer.sharedServer.getTalkWithTalkId(talkId, callback: { (talk:TalkDetail) -> Void in
            if self.presentedViewController != nil {
                self.dismissViewControllerAnimated(false, completion: { () -> Void in
                    self.showTalkDetailForTalk(talk, play: play)
                })
            } else {
                self.showTalkDetailForTalk(talk, play: play)
            }
        })
    }
    
    private func showTalkDetailForTalk(talk:TalkDetail, play:Bool) {
        if let talkDetailController = self.storyboard?.instantiateViewControllerWithIdentifier("TalkDetailViewController") as? TalkDetailViewController {
            self.presentViewController(talkDetailController, animated: false, completion: { () -> Void in
                talkDetailController.talkDetail = talk
                if play {
                    talkDetailController.play()
                }
            })
        }
    }
}

extension TracksViewController : UICollectionViewDelegate {
    
}

