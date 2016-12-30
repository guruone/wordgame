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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAuthViewController(notification:)), name: PlayerAuthentificator.presentVCNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authentificationSuccess(notification:)), name: PlayerAuthentificator.authentificatedNotificationName, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        print("deinit", self)
    }
}

fileprivate extension BaseViewController {
    
    func presentAnimated(viewController: UIViewController, completion: (() -> Void)?) {
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while let _presentedVC = topVC?.presentedViewController {
            topVC = _presentedVC
        }
        
        topVC?.present(viewController, animated: true, completion: completion)
        
    }
}

// MARK: Present Player Auth
private extension BaseViewController {
    
    @objc func presentAuthViewController(notification: Notification) {
        if let authPlayer = notification.object as? PlayerAuthentificator, let authVC = authPlayer.authentificationViewController {
            func completion() {
                presentAnimated(viewController: authVC, completion: nil)
            }
            
            if presentedViewController != nil {
                dismiss(animated: true, completion: completion)
                
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
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        presentAnimated(viewController: vc, completion: nil)
    }
}

// MARK: MatchMakerDelegate
extension BaseViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.gkmatch = match
        vc.gkoponent = oponent
        presentAnimated(viewController: vc, completion: nil)
    }
    
    func ended(with error: Error?) {
        print(error!.localizedDescription)
    }
}

