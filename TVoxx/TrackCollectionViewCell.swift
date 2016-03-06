//
//  TrackCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 02/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AlamofireImage

class TrackCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView:UICollectionView!
    
    var track:Track? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func canBecomeFocused() -> Bool {
        return false
    }
}

extension TrackCollectionViewCell: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let talks = self.track?.talks {
            return talks.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath) as! TalkCollectionViewCell
        cell.talk = self.track?.talks[indexPath.row]
        return cell
    }
}

extension TrackCollectionViewCell: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let talk = self.track?.talks[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName("talkSelected", object: self, userInfo: ["selectedTalk":talk!])
    }
}