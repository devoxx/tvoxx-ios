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
    
    fileprivate var selectedTalk:TalkListItem?
    fileprivate var tapGestureRecognizer:UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchResultsViewController.tapped(_:)))
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTalkDetail" {
            if let talkDetailViewController = segue.destination as? TalkDetailViewController {
                talkDetailViewController.talk = self.selectedTalk
            }
        }
    }
}

extension SearchResultsViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.characters.count >= 3 {
            self.noResultLabel.isHidden = true
            self.loadingIndicator.startAnimating()
            self.loadingView.isHidden = false
            TVoxxServer.sharedServer.searchForText(searchText, callback: { (results:[TalkListItem]) -> Void in
                self.searchResults = results
                self.loadingView.isHidden = true
                self.collectionView.reloadData()
                if results.count == 0 {
                    self.noResultLabel.text = NSLocalizedString("No result found", comment: "")
                    self.noResultLabel.isHidden = false
                } else {
                    self.noResultLabel.isHidden = true
                }
            })
        } else {
            self.searchResults = [TalkListItem]()
            self.collectionView.reloadData()
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let results = self.searchResults, results.count > 0 {
            return results.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TalkCell", for: indexPath) as! TalkCollectionViewCell
        cell.talk = self.searchResults![indexPath.row]
        return cell
    }


}

extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedTalk = self.searchResults![indexPath.row]
        self.performSegue(withIdentifier: "showTalkDetail", sender: self)
    }
}
