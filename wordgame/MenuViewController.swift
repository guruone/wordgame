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

class MenuViewController: BaseViewController {
    
    fileprivate var isViewDecorated = false
    
    fileprivate let rewardAd = AdsContainer.shared.rewardAd
    fileprivate let interstitialAd = AdsContainer.shared.videoInterstitialAd
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
    
    fileprivate let bonus = BonusPoints()
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerAuthentificated), name: PlayerAuthentificator.authentificatedNotificationName, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rewardAd.ad.isReady {
            rewardAd(isReady: rewardAd.ad)
            
        } else {
            rewardAd(isLoading: rewardAd.ad)
        }
        rewardAd.delegate = self
        
        interstitialAd.delegate = self

        bonusNextGameLabel.text = bonusNextGameLabelTemplate.replacingOccurrences(of: "%@", with: "\(bonus.currBonusInPerc)")
        
        if !isViewDecorated {
            isViewDecorated = true
            // GRAFIKA
            view.extAddCenterRound()
            view.extAddVerticalLinesFromTop(to: gameMenuStackView, offsetFromEdges: 50)
            view.extAddVerticalLinesFromTop(to: leaderBoardView, offsetFromEdges: 33)
            view.extAddVerticalLinesFromTop(to: bonusNextGameView, offsetFromEdges: 3)
            bonusNextGameView.extAddVerticalLinesFromTop(to: watchVideoButtonView, offsetFromEdges: 50, renderToView: view)
            
            view.extRemoveWithAnimation(layer: viewMask)
        }
        
        if PlayerAuthentificator.shared.isAuthenticated() {
            playerAuthentificated()
            
        } else {
            playerUnauthetificated()
        }
        
        if presentInterstitialAd {
            presentInterstitialAd = false
            #if DEBUG
                print(#function, self, "presentInterstitialAd", presentInterstitialAd)
            #else
                interstitialAd.ad.present(fromRootViewController: self)
            #endif
        }
    }
    
    @IBAction func unwindToMenuVCWithAd(segue: UIStoryboardSegue) {
        // MARK: VIDEO OD GOOGLE + CNT
        let kPlayInterstitialAd = "MenuVC.PlayInterstitialAd"
        var adCnt = UserDefaults.standard.integer(forKey: kPlayInterstitialAd)
        adCnt += 1
        if adCnt > 1 && interstitialAd.ad.isReady {
            adCnt = 0
            presentInterstitialAd = true
        }
        UserDefaults.standard.set(adCnt, forKey: kPlayInterstitialAd)
    }
}

fileprivate extension MenuViewController {
    
    @objc func playerAuthentificated() {
        leaderBoardButton.isEnabled = true
        multiPlayerButton.isEnabled = true
    }
    
    func playerUnauthetificated() {
        leaderBoardButton.isEnabled = false
        multiPlayerButton.isEnabled = false
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
    
    func addWillLeaveApplication() {
        
    }
    
}
