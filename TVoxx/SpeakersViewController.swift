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
    
    private var speakers:[SpeakerListItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadingIndicator.startAnimating()
        self.loadingView.hidden = false
        self.loadingIndicator.hidden = false
        self.collectionView.hidden = true
        
        TVoxxServer.sharedServer.getSpeakers { (speakers:[SpeakerListItem]) in
            if speakers.count == 0 {
                self.loadingLabel.text = NSLocalizedString("Could not find any speaker", comment:"")
                self.loadingIndicator.hidden = true
                self.loadingView.hidden = false
            } else {
                self.speakers = speakers
                self.collectionView.reloadData()
                self.loadingView.hidden = true
                self.collectionView.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SpeakersViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let speakers = self.speakers {
            return speakers.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SpeakerCell", forIndexPath: indexPath) as! SpeakerCollectionViewCell
        cell.speaker = self.speakers![indexPath.row]
        return cell
    }
}

extension SpeakersViewController : UICollectionViewDelegate {
    
}