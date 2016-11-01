//
//  FirstViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 20/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TracksViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var tracks = [Track]()
    fileprivate var selectedTalk: TalkListItem?
    fileprivate var tapGestureRecognizer: UIGestureRecognizer?
    
    fileprivate var selectionObserver:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TracksViewController.tapped(_:)))
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
        
        self.collectionView.isHidden = true
        self.loadingIndicator.startAnimating()
        self.loadingView.isHidden = false
        
        TVoxxServer.sharedServer.getTracks { (tracks:[Track]) -> Void in
            if tracks.count == 0 {
                self.loadingLabel.text = NSLocalizedString("No talk to load", comment:"")
                self.loadingIndicator.isHidden = true
                self.loadingView.isHidden = false
            } else {
                self.loadingView.isHidden = true
                self.tracks = tracks
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
            }
        }
        
        self.selectionObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "talkSelected"), object: nil, queue: OperationQueue.main) { (notification:Notification) -> Void in
            self.selectedTalk = notification.userInfo!["selectedTalk"] as? TalkListItem
            self.performSegue(withIdentifier: "showTalkDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destination as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let selectionObserver = self.selectionObserver {
            NotificationCenter.default.removeObserver(selectionObserver)
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TracksViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackCell", for: indexPath) as! TrackCollectionViewCell
        cell.track = self.tracks[indexPath.section]
        cell.setNeedsLayout()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrackHeader", for: indexPath) as! TrackCollectionReusableView
            headerView.titleLabel.text = self.tracks[indexPath.section].title
            return headerView
        default:
            assert(false, "Unexpected supplementary view type")
            return UICollectionReusableView()
        }
    }
    
    func openTalkWithTalkId(_ talkId:String, play:Bool) {
        TVoxxServer.sharedServer.getTalkWithTalkId(talkId, callback: { (talk:TalkDetail) -> Void in
            if self.presentedViewController != nil {
                self.dismiss(animated: false, completion: { () -> Void in
                    self.showTalkDetailForTalk(talk, play: play)
                })
            } else {
                self.showTalkDetailForTalk(talk, play: play)
            }
        })
    }
    
    fileprivate func showTalkDetailForTalk(_ talk:TalkDetail, play:Bool) {
        if let talkDetailController = self.storyboard?.instantiateViewController(withIdentifier: "TalkDetailViewController") as? TalkDetailViewController {
            self.present(talkDetailController, animated: false, completion: { () -> Void in
                talkDetailController.talkDetail = talk
                if play {
                    talkDetailController.play()
                }
            })
        }
    }
}

extension TracksViewController : UICollectionViewDelegate {
    
}

