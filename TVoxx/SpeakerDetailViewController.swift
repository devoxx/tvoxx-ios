//
//  SpeakerDetailViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 12/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AlamofireImage
import AVKit
import AVFoundation

class SpeakerDetailViewController: UIViewController {
    @IBOutlet weak var loadingView:UIStackView!
    @IBOutlet weak var loadingLabel:UILabel!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var detailView:UIStackView!
    @IBOutlet weak var companyLabel:UILabel!
    @IBOutlet weak var languageLabel:UILabel!
    @IBOutlet weak var bioLabel:UILabel!
    @IBOutlet weak var talksCollectionView:UICollectionView!
    @IBOutlet weak var avatarImageView:UIImageView!

    var speaker: SpeakerListItem? {
        didSet {
            guard self.loadingLabel != nil else { return }
            if let speaker = self.speaker {
                self.loadingLabel.text = speaker.firstName + " " + speaker.lastName
            } else {
                self.loadingLabel.text = ""
            }
        }
    }
    private var speakerDetail:SpeakerDetail?
    private var tapGestureRecognizer:UITapGestureRecognizer?
    private var selectedTalk:TalkListItem?
    
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
        
        self.nameLabel.hidden = true
        self.detailView.hidden = true
        self.talksCollectionView.hidden = true
        
        if let speaker = self.speaker {
            self.loadingView.hidden = false
            self.loadingLabel.text = speaker.firstName + " " + speaker.lastName + "..."
            self.loadingIndicator.startAnimating()
            TVoxxServer.sharedServer.getSpeakerWithUuid(speaker.uuid) { (speakerDetail: SpeakerDetail) in
                self.speakerDetail = speakerDetail
                self.nameLabel.text = speakerDetail.firstName + " " + speakerDetail.lastName
                self.companyLabel.text = speakerDetail.company
                self.bioLabel.text = speakerDetail.bio
                self.languageLabel.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: speakerDetail.lang)
                if let avatarUrl = speakerDetail.avatarUrl {
                    self.avatarImageView.af_setImageWithURL(NSURL(string: avatarUrl)!, placeholderImage:UIImage(named: "talk"))
                } else {
                    self.avatarImageView.image = UIImage(named: "talk")
                }
                
                self.talksCollectionView.reloadData()
                
                self.loadingView.hidden = true
                self.loadingLabel.hidden = true
                self.nameLabel.hidden = false
                self.detailView.hidden = false
                self.talksCollectionView.hidden = false
            }
        } else {
            self.loadingView.hidden = true
            self.loadingLabel.text = NSLocalizedString("No speaker to load", comment: "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destinationViewController as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
}

extension SpeakerDetailViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let speaker = self.speakerDetail {
            return speaker.talks.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath) as! TalkCollectionViewCell
        cell.talk = self.speakerDetail!.talks[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TalksHeader", forIndexPath: indexPath) as! TalksCollectionReusableView
            headerView.titleLabel.text = NSLocalizedString("Talks", comment:"")
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
}

extension SpeakerDetailViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedTalk = self.speakerDetail?.talks[indexPath.row]
        self.performSegueWithIdentifier("showTalkDetail", sender: self)
    }
}
