//
//  MenuViewController.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds

class MenuViewController: UIViewController {
    
    fileprivate let rewardAd = RewardAd()
    fileprivate let interstitialAd = VideoInterstitialAd()
    fileprivate var presentInterstitialAd = false
    
    fileprivate lazy var viewMask: CALayer = {
        let image = UIImage(named: "background")!
        let color = UIColor(patternImage: image)
        let mask = CALayer()
        mask.frame = self.view.bounds
        mask.backgroundColor = color.cgColor
        mask.zPosition = CGFloat.greatestFiniteMagnitude
        return mask
    }()
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()
    
    fileprivate lazy var gkscore: Score = {
        return Score()
    }()
    
    fileprivate let bonus = BonusPoints.shared
    
    @IBOutlet weak var leaderBoardButton: UIButton!
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!

    @IBOutlet weak var bonusNextGameLabel: UILabel!
    fileprivate var bonusNextGameLabelTemplate = ""
    
    
    @IBOutlet weak var bonusNextGameView: UIView!
    @IBOutlet weak var gameMenuStackView: UIStackView!
    @IBOutlet weak var watchVideoButtonView: UIView!
    @IBOutlet weak var leaderBoardView: UIView!
    
    @IBAction func onLeaderBoardClick() {
        let leaderBoardVC = gkscore.createLeaderBoard(delegateView: self)
        present(leaderBoardVC, animated: true, completion: nil)
    }
    
    @IBAction func onSinglePlayerClick() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: SinglePlayerViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func onMultiPlayerClick() {
        let vc = multiPlayerMatchMaker.createViewController()
        present(vc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var watchVideoToBonusButton: UIButton!
    
    @IBAction func onWatchVideoToBonus(_ sender: Any) {
        rewardAd.ad.present(fromRootViewController: self)
    }
}

// MARK: LIFECYCLE
extension MenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)
        
        view.extSetLetterBlueBackground()

        bonusNextGameLabelTemplate = bonusNextGameLabel.text!
        watchVideoToBonusButton.isEnabled = false
        rewardAd.delegate = self
        
        interstitialAd.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bonusNextGameLabel.text = bonusNextGameLabelTemplate.replacingOccurrences(of: "%@", with: "\(bonus.currBonusInPerc)")
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: gameMenuStackView, offsetFromEdges: 50)
        view.extAddVerticalLinesFromTop(to: leaderBoardView, offsetFromEdges: 33)
        view.extAddVerticalLinesFromTop(to: bonusNextGameView, offsetFromEdges: 3)
        bonusNextGameView.extAddVerticalLinesFromTop(to: watchVideoButtonView, offsetFromEdges: 50, renderToView: view)
        
        view.extRemoveWithAnimation(layer: viewMask)
        
        if presentInterstitialAd {
            interstitialAd.ad.present(fromRootViewController: self)
        }
    }
    
    @IBAction func unwindToMenuVCWithAd(segue: UIStoryboardSegue) {
        // TODO: miesto na video od google
        if interstitialAd.ad.isReady {
            presentInterstitialAd = true
        }
    }
}


// MARK: MatchMakerDelegate
extension MenuViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.gkmatch = match
        vc.gkoponent = oponent
        present(vc, animated: true, completion: nil)
    }
    
    func ended(with error: Error?) {
        print(error!.localizedDescription)
    }
}

// MARK: UINavigationControllerDelegate LEADER BOARD DELEGATE
extension MenuViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: RewardAdDelegate
extension MenuViewController: RewardAdDelegate {
    
    func rewardAd(isLoading rewardAd: GADRewardBasedVideoAd) {
        watchVideoToBonusButton.isEnabled = false
    }
    
    func rewardAd(didRewardUser reward: GADAdReward) {
        watchVideoToBonusButton.isEnabled = false
        bonus.addBonus(0.1)
        bonusNextGameLabel.text = bonusNextGameLabelTemplate.replacingOccurrences(of: "%@", with: "\(bonus.currBonusInPerc)")
    }
    
    func rewardAd(isReady rewardAd: GADRewardBasedVideoAd) {
        watchVideoToBonusButton.isEnabled = true
    }
}

// MARK: InterstitialAdDelegate
extension MenuViewController: InterstitialAdDelegate {
    
    func adIsReady(_ ad: GADInterstitial) {
        
    }
    
    func adDidDismissScreen() {
        
    }
    
}
