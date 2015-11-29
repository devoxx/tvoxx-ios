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

class TalksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView:UICollectionView!
    
    private var tracks = [Track]()
    var selectedTalk:Talk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        TVoxxServer.sharedServer.getTracks { (tracks:[Track]) -> Void in
            self.tracks = tracks
            self.collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tracks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("TrackCell", forIndexPath: indexPath) as! TrackCollectionViewCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let trackCell = cell as? TrackCollectionViewCell {
            let track = self.tracks[indexPath.row]
            trackCell.configureCellWithTrack(track, parentViewController:self)
        }
    }

    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showVideo") {
            if let playerViewController = segue.destinationViewController as? AVPlayerViewController, talk = self.selectedTalk {
                let videos = HCYoutubeParser.h264videosWithYoutubeURL(NSURL(string: talk.youtubeUrl)!)
                let videoUrl = NSURL(string: videos["hd720"] as! String)!
                let player = AVPlayer(URL: videoUrl)
                playerViewController.player = player
            }
        }
    }
}

