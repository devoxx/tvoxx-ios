//
//  TalkCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 02/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import Cosmos
import YoutubeSourceParserKit
import AVKit
import AVFoundation

class TalkCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    
    var talk: TalkListItem? {
        didSet {
            if let talk = talk {
                self.titleLabel.text = talk.title
                self.imageView.af_setImage(withURL:URL(string: talk.thumbnailUrl)!)
            } else {
                self.titleLabel.text = ""
                self.imageView.image = nil
            }
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.titleLabel.textColor = UIColor(red: 245/255.0, green: 175/255.0, blue: 51/255.0, alpha: 1.0)
                self.titleLabel.frame.origin.y += 40
                }, completion: nil)
        } else {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.titleLabel.textColor = UIColor.white
                self.titleLabel.frame.origin.y -= 40
                }, completion: nil)
        }
    }
    
    func play() -> AVPlayer? {
        let talk = self.talk!
        
        var videoInfo = Youtube.h264videosWithYoutubeID(talk.youtubeVideoId)
        if let videoURLString = videoInfo?["url"] as? String {
            let asset = AVAsset(url: URL(string: videoURLString)!)
            let playerItem = AVPlayerItem(asset: asset)
            
            let titleMetadata = AVMutableMetadataItem()
            titleMetadata.key = AVMetadataCommonKeyTitle as (NSCopying & NSObjectProtocol)?
            titleMetadata.keySpace = AVMetadataKeySpaceCommon
            titleMetadata.locale = Locale.current
            titleMetadata.value = talk.title as (NSCopying & NSObjectProtocol)?
            
            let descriptionMetadata = AVMutableMetadataItem()
            descriptionMetadata.key = AVMetadataCommonKeyDescription as (NSCopying & NSObjectProtocol)?
            descriptionMetadata.keySpace = AVMetadataKeySpaceCommon
            descriptionMetadata.locale = Locale.current
            descriptionMetadata.value = talk.summary as (NSCopying & NSObjectProtocol)?
            
            playerItem.externalMetadata = [titleMetadata, descriptionMetadata]
            
            if let track = talk.trackTitle {
                let genreMetadata = AVMutableMetadataItem()
                genreMetadata.locale = Locale.current
                genreMetadata.identifier = AVMetadataIdentifierQuickTimeMetadataGenre
                genreMetadata.value = track as (NSCopying & NSObjectProtocol)?
                playerItem.externalMetadata.append(genreMetadata)
            }
            
            if let image = self.imageView.image {
                let artworkMetadata = AVMutableMetadataItem()
                artworkMetadata.locale = Locale.current
                artworkMetadata.key = AVMetadataCommonKeyArtwork as (NSCopying & NSObjectProtocol)?
                artworkMetadata.keySpace = AVMetadataKeySpaceCommon
                artworkMetadata.value = UIImageJPEGRepresentation(image, 1.0) as (NSCopying & NSObjectProtocol)?
                playerItem.externalMetadata.append(artworkMetadata)
            }
            
            let player = AVPlayer(playerItem: playerItem)
            return player
        } else {
            return nil
        }
    }
}
