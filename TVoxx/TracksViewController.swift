//
//  FirstViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 20/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import HCYoutubeParser
import AVFoundation
import AVKit

class TracksViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private var tracks = [Track]()
    var selectedTalk: TalkListItem?
    
    private var selectionObserver:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        }
    }
}

extension TracksViewController : UICollectionViewDelegate {
    
}

