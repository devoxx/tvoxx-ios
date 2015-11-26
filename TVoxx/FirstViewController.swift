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

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView:UICollectionView!
    
    private var talks = [Talk]()
    private var selectedTalk:Talk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        TVoxxServer.sharedServer.getTalks { (talks:[Talk]) -> Void in
            self.talks = talks
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
        return self.talks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath) as! TalkCollectionViewCell
        
        let talk = self.talks[indexPath.row]
        cell.configureCellWithTalk(talk)
        
        return cell
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedTalk = self.talks[indexPath.row]
        self.performSegueWithIdentifier("showVideo", sender: self)
    }
}

