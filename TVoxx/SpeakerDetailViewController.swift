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
    fileprivate var speakerDetail:SpeakerDetail?
    fileprivate var tapGestureRecognizer:UITapGestureRecognizer?
    fileprivate var selectedTalk:TalkListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SpeakerDetailViewController.tapped(_:)))
        self.tapGestureRecognizer?.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue as Int)]
        self.view.addGestureRecognizer(self.tapGestureRecognizer!)
    }
    
    func tapped(_ sender:UITapGestureRecognizer) {
        if sender.state == .ended {
            if let focusedCell = UIScreen.main.focusedView as? TalkCollectionViewCell {
                if let player = focusedCell.play() {
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.present(playerController, animated: true, completion: { () -> Void in
                        player.play()
                    })
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.nameLabel.isHidden = true
        self.detailView.isHidden = true
        self.talksCollectionView.isHidden = true
        
        if let speaker = self.speaker {
            self.loadingView.isHidden = false
            self.loadingLabel.text = speaker.firstName + " " + speaker.lastName + "..."
            self.loadingIndicator.startAnimating()
            TVoxxServer.sharedServer.getSpeakerWithUuid(speaker.uuid) { (speakerDetail: SpeakerDetail) in
                self.speakerDetail = speakerDetail
                self.nameLabel.text = speakerDetail.firstName + " " + speakerDetail.lastName
                if let company = speakerDetail.company {
                    self.companyLabel.text = company
                } else {
                    self.companyLabel.text = ""
                }
                self.bioLabel.text = speakerDetail.bio
                self.languageLabel.text = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: speakerDetail.lang)
                if let avatarUrl = speakerDetail.avatarUrl {
                    self.avatarImageView.af_setImage(withURL:URL(string: avatarUrl)!, placeholderImage:UIImage(named: "talk"))
                } else {
                    self.avatarImageView.image = UIImage(named: "talk")
                }
                
                self.talksCollectionView.reloadData()
                
                self.loadingView.isHidden = true
                self.loadingLabel.isHidden = true
                self.nameLabel.isHidden = false
                self.detailView.isHidden = false
                self.talksCollectionView.isHidden = false
            }
        } else {
            self.loadingView.isHidden = true
            self.loadingLabel.text = NSLocalizedString("No speaker to load", comment: "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destination as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
}

extension SpeakerDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let speaker = self.speakerDetail {
            return speaker.talks.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalkCell", for: indexPath) as! TalkCollectionViewCell
        cell.talk = self.speakerDetail!.talks[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TalksHeader", for: indexPath) as! TalksCollectionReusableView
            headerView.titleLabel.text = NSLocalizedString("Talks", comment:"")
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
}

extension SpeakerDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedTalk = self.speakerDetail?.talks[indexPath.row]
        self.performSegue(withIdentifier: "showTalkDetail", sender: self)
    }
}
