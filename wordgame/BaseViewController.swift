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
    fileprivate let matchInviteListener = MatchInviteListener()
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAuthViewController(notification:)), name: PlayerAuthentificator.presentVCNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authentificationSuccess(notification:)), name: PlayerAuthentificator.authentificatedNotificationName, object: nil)
    }
}

fileprivate extension BaseViewController {
    
    func isVCPresented() -> Bool {
        return isViewLoaded && view.window != nil
    }
}

// MARK: Present Player Auth
private extension BaseViewController {
    
    @objc func presentAuthViewController(notification: Notification) {
        guard isVCPresented() else {
            return
        }
        
        if let authPlayer = notification.object as? PlayerAuthentificator, let authVC = authPlayer.authentificationViewController {
            func completion() {
                present(authVC, animated: true, completion: nil)
            }
            
            if presentedViewController != nil {
                presentedViewController!.dismiss(animated: true, completion: completion)
                
            } else {
                completion()
            }
        }
    }
    
    @objc func authentificationSuccess(notification: Notification) {
        if let playerAuth = notification.object as? PlayerAuthentificator, let player = playerAuth.authentificatedLocalPlayer {
            guard !matchInviteListenerDidRegister else {
                return
            }
            
            matchInviteListenerDidRegister = true
            player.unregisterAllListeners()
            matchInviteListener.delegate = self
            player.register(matchInviteListener)
        }
    }
}

// MARK: MatchInviteDelegate
extension BaseViewController: MatchInviteDelegate {
    
    func matchDidInvite(_ invite: GKInvite) {
        guard isVCPresented() else {
            return
        }
        
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        present(vc, animated: true, completion: nil)
    }
}

// MARK: MatchMakerDelegate
extension BaseViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        guard isVCPresented() else {
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.gkmatch = match
        vc.gkoponent = oponent
        present(vc, animated: true, completion: nil)
    }
    
    func ended(with error: Error?) {
        print(error!.localizedDescription)
    }
}

