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
    
    var presentPlayerAuthVCNotification: NSObjectProtocol?
    var playerAuthSuccessNotification: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentPlayerAuthVCNotification = NotificationCenter.default.addObserver(forName: PlayerAuthentificator.presentVCNotificationName, object: nil, queue: OperationQueue.main) { [unowned self] (notification: Notification) in
            print("presentPlayerAuthVCNotification")
            if let authPlayer = notification.object as? PlayerAuthentificator, let authVC = authPlayer.authentificationViewController {
                self.presentOnTopView(viewController: authVC)
            }
        }
        
        playerAuthSuccessNotification = NotificationCenter.default.addObserver(forName: PlayerAuthentificator.authentificatedNotificationName, object: nil, queue: .main, using: { [unowned self] (notification: Notification) in
            print("playerAuthSuccessNotification")
            if let playerAuth = notification.object as? PlayerAuthentificator, let player = playerAuth.authentificatedLocalPlayer {
                guard !self.matchInviteListenerDidRegister else {
                    return
                }
                
                self.matchInviteListenerDidRegister = true
                player.unregisterAllListeners()
                self.matchInviteListener.delegate = self
                player.register(self.matchInviteListener)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        print(#function, self)
        if presentPlayerAuthVCNotification != nil {
            NotificationCenter.default.removeObserver(presentPlayerAuthVCNotification!)
        }
        if playerAuthSuccessNotification != nil {
            NotificationCenter.default.removeObserver(playerAuthSuccessNotification!)
        }
    }
}

fileprivate extension BaseViewController {
    
    func presentOnTopView(viewController: UIViewController) {
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        
        if topVC?.presentedViewController != nil {
            topVC?.dismiss(animated: false, completion: {
                topVC?.present(viewController, animated: true)
            })
            
        } else {
            topVC?.present(viewController, animated: true)
        }
    }
}

// MARK: MatchInviteDelegate
extension BaseViewController: MatchInviteDelegate {
    
    func matchDidInvite(_ invite: GKInvite) {
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        presentOnTopView(viewController: vc)
    }
}

// MARK: MatchMakerDelegate
extension BaseViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.gkmatch = match
        vc.gkoponent = oponent
        presentOnTopView(viewController: vc)
    }
    
    func ended(with error: Error?) {
        print("ended", self)
        dismiss(animated: true, completion: nil)
        print(error!.localizedDescription)
    }
}

