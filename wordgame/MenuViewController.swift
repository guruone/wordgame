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
    
    fileprivate lazy var viewMask: CALayer = {
        let image = UIImage(named: "background")!
        let color = UIColor(patternImage: image)
        let mask = CALayer()
        mask.frame = self.view.bounds
        mask.backgroundColor = color.cgColor
        mask.zPosition = CGFloat.greatestFiniteMagnitude
        return mask
    }()
    
    fileprivate let playerAuth = PlayerAuthentificator()
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()
    
    fileprivate lazy var gkscore: Score = {
        return Score()
    }()
    
    fileprivate let bonus = BonusPoints.shared
    
    fileprivate let videoAd = VideoInterstitialAd()
    
    fileprivate var playerIsAuthetificated = false {
        didSet {
            if presentedViewController != nil { // alert pozri viewDidApear
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            
            if playerIsAuthetificated {
                buttonsEnabled()
                
            } else {
                buttonsDisabled()
            }
        }
    }
    
    @IBOutlet weak var leaderBoardButton: UIButton!
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!

    @IBOutlet weak var bonusNextGameLabel: UILabel!
    fileprivate var bonusNextGameLabelTemplate = ""
    
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
    
    fileprivate var ad: GADInterstitial?
    
    @IBOutlet weak var watchVideoToBonusButton: UIButton!
    
    @IBAction func onWatchVideoToBonus(_ sender: Any) {
        ad?.present(fromRootViewController: self)
    }
    
    fileprivate func buttonsDisabled() {
        leaderBoardButton.isEnabled = false
        singlePlayerButton.isEnabled = false
        multiPlayerButton.isEnabled = false
    }
    
    private func buttonsEnabled() {
        leaderBoardButton.isEnabled = true
        singlePlayerButton.isEnabled = true
        multiPlayerButton.isEnabled = true
    }
}

// MARK: LIFECYCLE
extension MenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)
        
        view.extSetLetterBlueBackground()
        
        buttonsDisabled()
        
        //        playerAuth.delegate = self
        //        playerAuth.authentificate()
        NotificationCenter.default.addObserver(self, selector: #selector(authentificationSuccess(notification:)), name: PlayerAuthentificator.authentificatedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAuthViewController(notification:)), name: PlayerAuthentificator.presentVCNotificationName, object: nil)
        
        bonusNextGameLabelTemplate = bonusNextGameLabel.text!
        watchVideoToBonusButton.isEnabled = false
        videoAd.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bonusNextGameLabel.text = bonusNextGameLabelTemplate.replacingOccurrences(of: "%@", with: "\(bonus.currBonusInPerc)")
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: watchVideoButtonView, offsetFromEdges: 50)
        view.extAddVerticalLinesFromTop(to: leaderBoardView, offsetFromEdges: 33)
        
        view.extRemoveWithAnimation(layer: viewMask)
        
        if !playerIsAuthetificated {
            let alert = UIAlertController(title: "Player Authentification", message: "please wait ...", preferredStyle: .actionSheet)
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: PlayerAuthentificatorDelagate
extension MenuViewController: PlayerAuthentificatorDelagate {
    
    func authentificationSuccess(notification: Notification) {
        if let playerAuth = notification.object as? PlayerAuthentificator {
            authentification(success: playerAuth.authentificatedLocalPlayer!)
        }
    }
    
    func authentification(success player: GKLocalPlayer) {
        playerIsAuthetificated = true
        player.unregisterAllListeners()
        let listener = MatchInviteListener()
        listener.delegate = self
        player.register(listener)
    }
    
    internal func authentification(failed error: Error) {
        //TODO: OSETRIT ERROR PRI AUTHENTIFIKACII
        print(error.localizedDescription)
        playerIsAuthetificated = false
    }
    
    func presentAuthViewController(notification: Notification) {
        if let authPlayer = notification.object as? PlayerAuthentificator {
            present(authentification: authPlayer.authentificationViewController!)
        }
    }

    func present(authentification viewController: UIViewController) {
        func completion() {
            present(viewController, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController!.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
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

// MARK: InterstitialAdDelegate
extension MenuViewController: InterstitialAdDelegate {
    
    func adIsReady(_ ad: GADInterstitial) {
        self.ad = ad
        watchVideoToBonusButton.isEnabled = true
    }
    
    func adDidDismissScreen() {
        watchVideoToBonusButton.isEnabled = false
        bonus.addBonus(0.1)
        bonusNextGameLabel.text = bonusNextGameLabelTemplate.replacingOccurrences(of: "%@", with: "\(bonus.currBonusInPerc)")
    }
}

// MARK: MatchInviteDelegate
extension MenuViewController: MatchInviteDelegate {
    
    func matchDidInvite(_ invite: GKInvite) {
        print("matchDidInvite")
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        present(vc, animated: true, completion: nil)
    }
}
