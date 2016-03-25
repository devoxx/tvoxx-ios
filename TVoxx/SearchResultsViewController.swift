//
//  SearchResultsViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 18/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SearchResultsViewController: UIViewController {
    @IBOutlet weak var loadingView:UIStackView!
    @IBOutlet weak var loadingLabel:UILabel!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var noResultLabel:UILabel!
    var searchResults:[TalkListItem]?
    
    private var selectedTalk:TalkListItem?
    private var tapGestureRecognizer:UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchResultsViewController.tapped(_:)))
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destinationViewController as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
}

extension SearchResultsViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text where searchText.characters.count >= 3 {
            self.noResultLabel.hidden = true
            self.loadingIndicator.startAnimating()
            self.loadingView.hidden = false
            TVoxxServer.sharedServer.searchForText(searchText, callback: { (results:[TalkListItem]) -> Void in
                self.searchResults = results
                self.loadingView.hidden = true
                self.collectionView.reloadData()
                if results.count == 0 {
                    self.noResultLabel.text = NSLocalizedString("No result found", comment: "")
                    self.noResultLabel.hidden = false
                } else {
                    self.noResultLabel.hidden = true
                }
            })
        } else {
            self.searchResults = [TalkListItem]()
            self.collectionView.reloadData()
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let results = self.searchResults where results.count > 0 {
            return results.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TalkCell", forIndexPath: indexPath) as! TalkCollectionViewCell
        cell.talk = self.searchResults![indexPath.row]
        return cell
    }
}

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedTalk = self.searchResults![indexPath.row]
        self.performSegueWithIdentifier("showTalkDetail", sender: self)
    }
}
