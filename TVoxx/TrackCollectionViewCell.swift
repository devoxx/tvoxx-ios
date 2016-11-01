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
    
    override var canBecomeFocused : Bool {
        return false
    }
}

extension TrackCollectionViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let talks = self.track?.talks {
            return talks.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalkCell", for: indexPath) as! TalkCollectionViewCell
        cell.talk = self.track?.talks[indexPath.row]
        return cell
    }
}

extension TrackCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let talk = self.track?.talks[indexPath.row]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "talkSelected"), object: self, userInfo: ["selectedTalk":talk!])
    }
}
