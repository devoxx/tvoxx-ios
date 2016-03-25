//
//  TalkDetailViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 05/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import Cosmos
import AlamofireImage
import YoutubeSourceParserKit
import AVFoundation
import AVKit
import FontAwesome_swift

class TalkDetailViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var conferenceLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var ratingGroup: UIStackView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var detailView: UIStackView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var speakersCollectionView: UICollectionView!
    @IBOutlet weak var playView:UIStackView!
    @IBOutlet weak var watchListView:UIStackView!
    @IBOutlet weak var playLabel:UILabel!
    @IBOutlet weak var watchListLabel:UILabel!
    @IBOutlet weak var watchListLoadingView:UIView!
    
    private var topFocusGuide = UIFocusGuide()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var selectedSpeaker:SpeakerListItem?
    
    var talk: TalkListItem? {
        didSet {
            guard self.loadingLabel != nil else { return }
            if let talk = self.talk {
                self.loadingLabel.text = talk.title + "..."
            } else {
                self.loadingLabel.text = ""
            }
        }
    }
    var talkDetail:TalkDetail? {
        didSet {
            if let talkDetail = self.talkDetail {
                self.titleLabel.text = talkDetail.title
                self.formatLabel.text = talkDetail.talkType
                self.conferenceLabel.text = talkDetail.conferenceLabel.stringByReplacingOccurrencesOfString(", ", withString: ",\n")
                self.trackLabel.text = talkDetail.trackTitle
                if let rating = talkDetail.averageRating {
                    self.ratingView.rating = rating
                    self.ratingLabel.text = String(format: NSLocalizedString("Out of %d votes", comment:""), talkDetail.numberOfRatings!)
                    self.ratingGroup.hidden = false
                } else {
                    self.ratingGroup.hidden = true
                }
                self.abstractLabel.text = talkDetail.summary
                self.languageLabel.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: talkDetail.lang)
                self.thumbnailView.af_setImageWithURL(NSURL(string: talkDetail.thumbnailUrl)!, placeholderImage: UIImage(named: "talk"))
                
                self.durationLabel.text = Utils.formatDuration(talkDetail.durationInSeconds)
                
                self.speakersCollectionView.reloadData()
                
                self.loadingView.hidden = true
                self.loadingLabel.hidden = true
                self.titleLabel.hidden = false
                self.detailView.hidden = false
                self.speakersCollectionView.hidden = false
                
                self.updateWatchListButton()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addToWatchlistButton.titleLabel?.font = UIFont.fontAwesomeOfSize(40)
        self.playButton.titleLabel?.font = UIFont.fontAwesomeOfSize(40)
        self.playButton.setTitle(String.fontAwesomeIconWithName(.Play), forState: .Normal)
        self.playLabel.text = NSLocalizedString("Play", comment: "") + "\n "
        
        self.ratingView.settings.fillMode = .Precise
        self.setupFocus()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TalkDetailViewController.tapped(_:)))
        self.tapGestureRecognizer?.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    func tapped(sender:UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.play()
        }
    }
    
    private func setupFocus() {
        view.addLayoutGuide(self.topFocusGuide)
        topFocusGuide.bottomAnchor.constraintEqualToAnchor(speakersCollectionView.topAnchor).active = true
        topFocusGuide.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        topFocusGuide.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        topFocusGuide.topAnchor.constraintEqualToAnchor(self.playButton.bottomAnchor).active = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleLabel.hidden = true
        self.detailView.hidden = true
        self.speakersCollectionView.hidden = true
        
        if let talk = self.talk {
            self.loadingView.hidden = false
            self.loadingLabel.text = talk.title + "..."
            self.loadingIndicator.startAnimating()
            TVoxxServer.sharedServer.getTalkWithTalkId(talk.talkId) { (talkDetail: TalkDetail) in
                self.talkDetail = talkDetail
            }
        } else {
            self.loadingView.hidden = true
            self.loadingLabel.text = NSLocalizedString("No talk to load", comment: "")
        }
        
        self.updateWatchListButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        if nextFocusedView.isKindOfClass(SpeakerCollectionViewCell) {
            self.topFocusGuide.preferredFocusedView = self.playButton
        } else {
            self.topFocusGuide.preferredFocusedView = self.speakersCollectionView
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var preferredFocusedView: UIView? {
        return self.playButton
    }
    
    @IBAction func playButtonTyped(sender: AnyObject) {
        self.play()
    }
    
    @IBAction func watchlistButtonTyped(sender: AnyObject) {
        if let talkDetail = self.talkDetail {
            WatchList.sharedWatchList.isTalkAlreadyInWatchList(talkDetail){ (result:Bool?, error:WatchListError?) in
                if let error = error {
                    switch error {
                    case .NotAuthenticated:
                        self.showAuthenticationError()
                    case .BackendError(let rootCause):
                        self.showBackendError(rootCause)
                    }
                } else {
                    if result! {
                        WatchList.sharedWatchList.removeTalkFromWatchList(talkDetail) { (error:WatchListError?) in
                            if let error = error {
                                switch error {
                                case .NotAuthenticated:
                                    self.showAuthenticationError()
                                case .BackendError(let rootCause):
                                    self.showBackendError(rootCause)
                                }
                            }
                            self.updateWatchListButton()
                        }
                    } else {
                        WatchList.sharedWatchList.addTalkToWatchList(talkDetail) { (error:WatchListError?) in
                            if let error = error {
                                switch error {
                                case .NotAuthenticated:
                                    self.showAuthenticationError()
                                case .BackendError(let rootCause):
                                    self.showBackendError(rootCause)
                                }
                            }
                            self.updateWatchListButton()
                        }
                    }
                }
            }
        }
    }
    
    func updateWatchListButton() {
        if let talkDetail = self.talkDetail {
            self.watchListView.hidden = true
            self.watchListLoadingView.hidden = false
            WatchList.sharedWatchList.isTalkAlreadyInWatchList(talkDetail){ (result:Bool?, error:WatchListError?) in
                self.watchListLoadingView.hidden = true
                if let error = error {
                    self.watchListView.hidden = true
                    switch error {
                    case .NotAuthenticated:
                        self.showAuthenticationError()
                    case .BackendError(let rootCause):
                        self.showBackendError(rootCause)
                    }
                } else {
                    if result! {
                        self.addToWatchlistButton.setTitle(String.fontAwesomeIconWithName(.MinusCircle), forState: .Normal)
                        self.watchListLabel.text = NSLocalizedString("Remove from\nwatchlist", comment: "")
                    } else {
                        self.addToWatchlistButton.setTitle(String.fontAwesomeIconWithName(.PlusCircle), forState: .Normal)
                        self.watchListLabel.text = NSLocalizedString("Add to\nwatchlist", comment: "")
                    }
                    self.watchListView.hidden = false
                }
                
            }
        } else {
            self.watchListView.hidden = true
        }
    }
    
    private func showBackendError(rootCause:NSError) {
        print(rootCause.debugDescription)
        let alert = UIAlertController(title: NSLocalizedString("Error while adding this talk to your watchlist", comment: ""),
                                      message: NSLocalizedString("Unknown error. Please try again later.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func showAuthenticationError() {
        let alert = UIAlertController(title: NSLocalizedString("Error while adding this talk to your watchlist", comment: ""),
                                      message: NSLocalizedString("You need to sign in to your iCloud account in order to add talks to your watch list. On the Home screen, launch Settings, tap Accounts, then tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", comment: ""),
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSpeakerDetail" {
            if let speakerDetailViewController = segue.destinationViewController as? SpeakerDetailViewController, selectedSpeaker = self.selectedSpeaker {
                speakerDetailViewController.speaker = selectedSpeaker
            }
        }
    }
    
    func play() {
        if let youtubeID = self.talkDetail?.youtubeVideoId {
            var videoInfo = Youtube.h264videosWithYoutubeID(youtubeID)
            if let videoURLString = videoInfo?["url"] as? String {
                let asset = AVAsset(URL: NSURL(string: videoURLString)!)
                let playerItem = AVPlayerItem(asset: asset)
                
                let titleMetadata = AVMutableMetadataItem()
                titleMetadata.key = AVMetadataCommonKeyTitle
                titleMetadata.keySpace = AVMetadataKeySpaceCommon
                titleMetadata.locale = NSLocale.currentLocale()
                titleMetadata.value = self.talkDetail!.title
                
                let descriptionMetadata = AVMutableMetadataItem()
                descriptionMetadata.key = AVMetadataCommonKeyDescription
                descriptionMetadata.keySpace = AVMetadataKeySpaceCommon
                descriptionMetadata.locale = NSLocale.currentLocale()
                descriptionMetadata.value = self.talkDetail!.summary
                
                playerItem.externalMetadata = [titleMetadata, descriptionMetadata]
                
                if let track = self.talkDetail?.trackTitle {
                    let genreMetadata = AVMutableMetadataItem()
                    genreMetadata.locale = NSLocale.currentLocale()
                    genreMetadata.identifier = AVMetadataIdentifierQuickTimeMetadataGenre
                    genreMetadata.value = track
                    playerItem.externalMetadata.append(genreMetadata)
                }
                
                if let image = self.thumbnailView.image {
                    let artworkMetadata = AVMutableMetadataItem()
                    artworkMetadata.locale = NSLocale.currentLocale()
                    artworkMetadata.key = AVMetadataCommonKeyArtwork
                    artworkMetadata.keySpace = AVMetadataKeySpaceCommon
                    artworkMetadata.value = UIImageJPEGRepresentation(image, 1.0)
                    playerItem.externalMetadata.append(artworkMetadata)
                }
                
                let player = AVPlayer(playerItem: playerItem)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.presentViewController(playerController, animated: true, completion: { () -> Void in
                    player.play()
                })
            }
        }
    }
}

extension TalkDetailViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let talk = self.talkDetail {
            if talk.speakers.count > 0 {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let talk = self.talkDetail {
            if talk.speakers.count > 0 {
                return talk.speakers.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SpeakerCell", forIndexPath: indexPath) as! SpeakerCollectionViewCell
        cell.speaker = self.talkDetail!.speakers[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SpeakersHeader", forIndexPath: indexPath) as! SpeakersCollectionReusableView
            headerView.titleLabel.text = NSLocalizedString("Speakers", comment:"")
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
}

extension TalkDetailViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedSpeaker = self.talkDetail?.speakers[indexPath.row]
        self.performSegueWithIdentifier("showSpeakerDetail", sender: self)
    }
}
