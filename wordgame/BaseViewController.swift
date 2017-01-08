//
//  BaseViewController.swift
//  wordgame
//
//  Created by Marek Mako on 28/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class BaseViewController: UIViewController {
    
    fileprivate var matchInviteListenerDidRegister = false
    fileprivate let matchInviteListener = MatchInviteListener.shared
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()
    
    private var presentPlayerAuthVCNotification: NSObjectProtocol?
    private var playerAuthSuccessNotification: NSObjectProtocol?
    private var playerDidInviteNotification: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentPlayerAuthVCNotification = NotificationCenter.default.addObserver(forName: PlayerAuthentificator.presentVCNotificationName, object: nil, queue: .main) { [unowned self] (notification: Notification) in
            #if DEBUG
                print("presentPlayerAuthVCNotification", self)
            #endif
            if let authPlayer = notification.object as? PlayerAuthentificator, let authVC = authPlayer.authentificationViewController {
                self.present(authVC, animated: true, completion: nil)
            }
        }
        
        playerAuthSuccessNotification = NotificationCenter.default.addObserver(forName: PlayerAuthentificator.authentificatedNotificationName, object: nil, queue: .main, using: { [unowned self] (notification: Notification) in
            #if DEBUG
                print("playerAuthSuccessNotification")
            #endif
            if let playerAuth = notification.object as? PlayerAuthentificator, let player = playerAuth.authentificatedLocalPlayer {
                guard !self.matchInviteListenerDidRegister else {
                    return
                }
                
                self.matchInviteListenerDidRegister = true
                player.unregisterAllListeners()
                player.register(self.matchInviteListener)
            }
        })
        
        playerDidInviteNotification = NotificationCenter.default.addObserver(forName: MatchInviteListener.playerDidAcceptInviteNotificationName, object: nil, queue: .main, using: { [unowned self] (notification: Notification) in
            #if DEBUG
                print("playerDidInviteNotification")
            #endif
            let invite = notification.userInfo!["invite"] as! GKInvite
            let vc = self.multiPlayerMatchMaker.createViewController(forInvite: invite)
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if presentPlayerAuthVCNotification != nil {
            NotificationCenter.default.removeObserver(presentPlayerAuthVCNotification!)
        }
        if playerAuthSuccessNotification != nil {
            NotificationCenter.default.removeObserver(playerAuthSuccessNotification!)
        }
        if playerDidInviteNotification != nil {
            NotificationCenter.default.removeObserver(playerDidInviteNotification!)
        }
    }
    
    deinit {
        #if DEBUG
            print(#function, self)
        #endif
    }
}

// MARK: MatchMakerDelegate
extension BaseViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        dismiss(animated: true, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
            vc.gkmatch = match
            vc.gkoponent = oponent
            vc.presentingVC = self
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    func ended(with error: Error?) {
        #if DEBUG
            print("MatchMakerDelegate.ended", self)
            print(error!.localizedDescription)
        #endif
        dismiss(animated: true, completion: nil)
    }
}

extension BaseViewController: PresentingViewController {
    
    func dismissPresentedVC() {
        // MARK: ak je zobrazeny menu controller pokusi sa po skonceni hry zobrazit reklamu
        if let menuVC = self as? MenuViewController {
            menuVC.countToInterstitialAd()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

