//
//  TrackCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 29/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit

class TrackCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var talksCollectionView:UICollectionView!
    
    private var track = Track(withTrackId: "", title: "", talks: [Talk]())
    private var parentViewController:TalksViewController?
    
    func configureCellWithTrack(track:Track, parentViewController:TalksViewController) {
        self.track = track
        self.parentViewController = parentViewController
        self.titleLabel.text = track.title
        self.talksCollectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.track.talks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let talkCell = cell as? TalkCollectionViewCell {
            talkCell.configureCellWithTalk(self.track.talks[indexPath.row])
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let talksViewController = self.parentViewController {
            talksViewController.selectedTalk = self.track.talks[indexPath.row]
            talksViewController.performSegueWithIdentifier("showVideo", sender: self)
        }
    }
}
