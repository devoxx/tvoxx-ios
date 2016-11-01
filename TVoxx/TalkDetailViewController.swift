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
import TVServices

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
    
    fileprivate var topFocusGuide = UIFocusGuide()
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    fileprivate var selectedSpeaker:SpeakerListItem?
    
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
                self.conferenceLabel.text = talkDetail.conferenceLabel.replacingOccurrences(of: ", ", with: ",\n")
                self.trackLabel.text = talkDetail.trackTitle
                if let rating = talkDetail.averageRating {
                    self.ratingView.rating = rating
                    self.ratingLabel.text = String.localizedStringWithFormat(NSLocalizedString("Out of %d votes", comment:""), talkDetail.numberOfRatings!)
                    self.ratingGroup.isHidden = false
                } else {
                    self.ratingGroup.isHidden = true
                }
                self.abstractLabel.text = talkDetail.summary
                self.languageLabel.text = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: talkDetail.lang)
                self.thumbnailView.af_setImage(withURL:URL(string: talkDetail.thumbnailUrl)!, placeholderImage: UIImage(named: "talk"))
                
                self.durationLabel.text = Utils.formatDuration(talkDetail.durationInSeconds)
                
                self.speakersCollectionView.reloadData()
                
                self.loadingView.isHidden = true
                self.loadingLabel.isHidden = true
                self.titleLabel.isHidden = false
                self.detailView.isHidden = false
                self.speakersCollectionView.isHidden = false
                
                self.updateWatchListButton()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addToWatchlistButton.titleLabel?.font = UIFont.fontAwesome(ofSize:40)
        self.playButton.titleLabel?.font = UIFont.fontAwesome(ofSize:40)
        self.playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        self.playLabel.text = NSLocalizedString("Play", comment: "") + "\n "
        
        self.ratingView.settings.fillMode = .precise
        self.setupFocus()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TalkDetailViewController.tapped(_:)))
        self.tapGestureRecognizer?.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue as Int)]
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    func tapped(_ sender:UITapGestureRecognizer) {
        if sender.state == .ended {
            self.play()
        }
    }
    
    fileprivate func setupFocus() {
        view.addLayoutGuide(self.topFocusGuide)
        topFocusGuide.bottomAnchor.constraint(equalTo: speakersCollectionView.topAnchor).isActive = true
        topFocusGuide.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        topFocusGuide.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        topFocusGuide.topAnchor.constraint(equalTo: self.playButton.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleLabel.isHidden = true
        self.detailView.isHidden = true
        self.speakersCollectionView.isHidden = true
        
        if let talk = self.talk {
            self.loadingView.isHidden = false
            self.loadingLabel.text = talk.title + "..."
            self.loadingIndicator.startAnimating()
            TVoxxServer.sharedServer.getTalkWithTalkId(talk.talkId) { (talkDetail: TalkDetail) in
                self.talkDetail = talkDetail
            }
        } else {
            self.loadingView.isHidden = true
            self.loadingLabel.text = NSLocalizedString("No talk to load", comment: "")
        }
        
        self.updateWatchListButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let nextFocusedView = context.nextFocusedView else { return }
        
        if nextFocusedView.isKind(of: SpeakerCollectionViewCell.self) {
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
    
    @IBAction func playButtonTyped(_ sender: AnyObject) {
        self.play()
    }
    
    @IBAction func watchlistButtonTyped(_ sender: AnyObject) {
        if let talkDetail = self.talkDetail {
            WatchList.sharedWatchList.isTalkAlreadyInWatchList(talkDetail){ (result:Bool?, error:WatchListError?) in
                if let error = error {
                    switch error {
                    case .notAuthenticated:
                        self.showAuthenticationError(NSLocalizedString("Impossible to access your watchlist", comment: ""))
                    case .backendError(let rootCause):
                        self.showBackendError(rootCause, title: NSLocalizedString("Impossible to access your watchlist", comment: ""))
                    }
                } else {
                    if result! {
                        WatchList.sharedWatchList.removeTalkFromWatchList(talkDetail) { (error:WatchListError?) in
                            if let error = error {
                                switch error {
                                case .notAuthenticated:
                                    self.showAuthenticationError(NSLocalizedString("Error while removing this talk from your watchlist", comment: ""))
                                case .backendError(let rootCause):
                                    self.showBackendError(rootCause, title: NSLocalizedString("Error while removing this talk from your watchlist", comment: ""))
                                }
                            }
                            self.updateWatchListButton()
                            NotificationCenter.default.post(name: NSNotification.Name.TVTopShelfItemsDidChange, object: nil)
                        }
                    } else {
                        WatchList.sharedWatchList.addTalkToWatchList(talkDetail) { (error:WatchListError?) in
                            if let error = error {
                                switch error {
                                case .notAuthenticated:
                                    self.showAuthenticationError(NSLocalizedString("Error while adding this talk to your watchlist", comment: ""))
                                case .backendError(let rootCause):
                                    self.showBackendError(rootCause, title: NSLocalizedString("Error while adding this talk to your watchlist", comment: ""))
                                }
                            }
                            self.updateWatchListButton()
                            NotificationCenter.default.post(name: NSNotification.Name.TVTopShelfItemsDidChange, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    func updateWatchListButton() {
        if let talkDetail = self.talkDetail {
            self.watchListView.isHidden = true
            self.watchListLoadingView.isHidden = false
            WatchList.sharedWatchList.isTalkAlreadyInWatchList(talkDetail){ (result:Bool?, error:WatchListError?) in
                self.watchListLoadingView.isHidden = true
                if let error = error {
                    self.watchListView.isHidden = true
                    switch error {
                    case .notAuthenticated:
                        NSLog("User is not authenticated")
                    case .backendError(let rootCause):
                        NSLog("CloudKit error: " + rootCause.localizedDescription)
                    }
                } else {
                    if result! {
                        self.addToWatchlistButton.setTitle(String.fontAwesomeIcon(name: .minusCircle), for: .normal)
                        self.watchListLabel.text = NSLocalizedString("Remove from\nwatchlist", comment: "")
                    } else {
                        self.addToWatchlistButton.setTitle(String.fontAwesomeIcon(name:.plusCircle), for: .normal)
                        self.watchListLabel.text = NSLocalizedString("Add to\nwatchlist", comment: "")
                    }
                    self.watchListView.isHidden = false
                }
            }
        } else {
            self.watchListView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeakerDetail" {
            if let speakerDetailViewController = segue.destination as? SpeakerDetailViewController, let selectedSpeaker = self.selectedSpeaker {
                speakerDetailViewController.speaker = selectedSpeaker
            }
        }
    }
    
    func play() {
        if let youtubeID = self.talkDetail?.youtubeVideoId {
            var videoInfo = Youtube.h264videosWithYoutubeID(youtubeID)
            if let videoURLString = videoInfo?["url"] as? String {
                let asset = AVAsset(url: URL(string: videoURLString)!)
                let playerItem = AVPlayerItem(asset: asset)
                
                let titleMetadata = AVMutableMetadataItem()
                titleMetadata.key = AVMetadataCommonKeyTitle as (NSCopying & NSObjectProtocol)?
                titleMetadata.keySpace = AVMetadataKeySpaceCommon
                titleMetadata.locale = Locale.current
                titleMetadata.value = self.talkDetail!.title as (NSCopying & NSObjectProtocol)?
                
                let descriptionMetadata = AVMutableMetadataItem()
                descriptionMetadata.key = AVMetadataCommonKeyDescription as (NSCopying & NSObjectProtocol)?
                descriptionMetadata.keySpace = AVMetadataKeySpaceCommon
                descriptionMetadata.locale = Locale.current
                descriptionMetadata.value = self.talkDetail!.summary as (NSCopying & NSObjectProtocol)?
                
                playerItem.externalMetadata = [titleMetadata, descriptionMetadata]
                
                if let track = self.talkDetail?.trackTitle {
                    let genreMetadata = AVMutableMetadataItem()
                    genreMetadata.locale = Locale.current
                    genreMetadata.identifier = AVMetadataIdentifierQuickTimeMetadataGenre
                    genreMetadata.value = track as (NSCopying & NSObjectProtocol)?
                    playerItem.externalMetadata.append(genreMetadata)
                }
                
                if let image = self.thumbnailView.image {
                    let artworkMetadata = AVMutableMetadataItem()
                    artworkMetadata.locale = Locale.current
                    artworkMetadata.key = AVMetadataCommonKeyArtwork as (NSCopying & NSObjectProtocol)?
                    artworkMetadata.keySpace = AVMetadataKeySpaceCommon
                    artworkMetadata.value = UIImageJPEGRepresentation(image, 1.0) as (NSCopying & NSObjectProtocol)?
                    playerItem.externalMetadata.append(artworkMetadata)
                }
                
                let player = AVPlayer(playerItem: playerItem)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true, completion: { () -> Void in
                    player.play()
                })
            }
        }
    }
}

extension TalkDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCollectionViewCell
        cell.speaker = self.talkDetail!.speakers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SpeakersHeader", for: indexPath) as! SpeakersCollectionReusableView
            headerView.titleLabel.text = NSLocalizedString("Speakers", comment:"")
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
}

extension TalkDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedSpeaker = self.talkDetail?.speakers[indexPath.row]
        self.performSegue(withIdentifier: "showSpeakerDetail", sender: self)
    }
}
