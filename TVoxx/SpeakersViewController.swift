//
//  SpeakersViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 11/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit

class SpeakersViewController: UIViewController {
    @IBOutlet weak var loadingView:UIStackView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var loadingIndicator:UIActivityIndicatorView!
    @IBOutlet weak var headerLabel:UILabel!
    @IBOutlet weak var loadingLabel:UILabel!
    
    fileprivate var speakers:[SpeakerListItem]?
    fileprivate var selectedSpeaker:SpeakerListItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadingIndicator.startAnimating()
        self.loadingView.isHidden = false
        self.loadingIndicator.isHidden = false
        self.collectionView.isHidden = true
        
        TVoxxServer.sharedServer.getSpeakers { (speakers:[SpeakerListItem]) in
            if speakers.count == 0 {
                self.loadingLabel.text = NSLocalizedString("Could not find any speaker", comment:"")
                self.loadingIndicator.isHidden = true
                self.loadingView.isHidden = false
            } else {
                self.speakers = speakers
                self.collectionView.reloadData()
                self.loadingView.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeakerDetail" {
            if let speakerDetailViewController = segue.destination as? SpeakerDetailViewController, let selectedSpeaker = self.selectedSpeaker {
                speakerDetailViewController.speaker = selectedSpeaker
            }
        }
    }
}

extension SpeakersViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let speakers = self.speakers {
            return speakers.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpeakerCell", for: indexPath) as! SpeakerCollectionViewCell
        cell.speaker = self.speakers![indexPath.row]
        return cell
    }
}

extension SpeakersViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedSpeaker = self.speakers![indexPath.row]
        self.performSegue(withIdentifier: "showSpeakerDetail", sender: self)
    }
}
