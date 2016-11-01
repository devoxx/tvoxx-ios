//
//  WatchlistViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WatchlistViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel:UILabel!
    fileprivate var talks = [TalkListItem]()
    fileprivate var selectedTalk:TalkListItem?
    fileprivate var tapGestureRecognizer:UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emptyLabel.text = NSLocalizedString("No talk in watchlist. To add some, go to individual talks and tap \"Add to watchlist\".", comment: "")
        self.emptyLabel.isHidden = false
        self.loadingView.isHidden = true
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WatchlistViewController.tapped(_:)))
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
        
        self.emptyLabel.isHidden = true
        self.loadingView.isHidden = false
        WatchList.sharedWatchList.moviesInWatchList { (talks:[TalkListItem]?, error:WatchListError?) in
            self.loadingView.isHidden = true
            if let error = error {
                self.emptyLabel.isHidden = false
                switch error {
                case .notAuthenticated:
                    self.emptyLabel.text = NSLocalizedString("You need to sign in to your iCloud account in order to use the watchlist feature. On the Home screen, launch Settings, tap Accounts, then tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", comment: "")
                case .backendError(let rootCause):
                    self.emptyLabel.text = NSLocalizedString("Impossible to load your watchlist", comment: "")
                    NSLog("CloudKit error: " + rootCause.localizedDescription)
                }
            } else {
                if let talks = talks, talks.count > 0 {
                    self.talks = talks
                } else {
                    self.talks = [TalkListItem]()
                    self.emptyLabel.text = NSLocalizedString("No talk in watchlist. To add some, go to individual talks and tap \"Add to watchlist\"", comment:"")
                    self.emptyLabel.isHidden = false
                }
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTalkDetail" {
            if let selectedTalk = self.selectedTalk, let talkDetailViewController = segue.destination as? TalkDetailViewController {
                talkDetailViewController.talk = selectedTalk
            }
        }
    }
    

}

extension WatchlistViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.talks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let talkCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalkCell", for: indexPath) as! TalkCollectionViewCell
        talkCell.talk = self.talks[indexPath.row]
        return talkCell
    }
}

extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedTalk = self.talks[indexPath.row]
        self.performSegue(withIdentifier: "showTalkDetail", sender: self)
    }
}
