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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentPlayerAuthVCNotification = NotificationCenter.default.addObserver(forName: PlayerAuthentificator.presentVCNotificationName, object: nil, queue: OperationQueue.main) { [unowned self] (notification: Notification) in
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
                self.matchInviteListener.delegate = self
                player.register(self.matchInviteListener)
            }
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
    }
    
    deinit {
        #if DEBUG
            print(#function, self)
        #endif
    }
}

// MARK: MatchInviteDelegate
extension BaseViewController: MatchInviteDelegate {
    
    func matchDidInvite(_ invite: GKInvite) {
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        present(vc, animated: true, completion: nil)
    }
}

// MARK: MatchMakerDelegate
extension BaseViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        dismiss(animated: true, completion: nil) // dismiss matchmakerVC
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.presentedDelegate = self
        vc.gkmatch = match
        vc.gkoponent = oponent
        present(vc, animated: true, completion: nil)
    }
    
    func ended(with error: Error?) {
        #if DEBUG
            print("MatchMakerDelegate.ended", self)
            print(error!.localizedDescription)
        #endif
        dismiss(animated: true, completion: nil)
    }
}

// MARK: PresentedDelegate
extension BaseViewController: PresentedDelegate {
    
    func dismissMe(_ viewController: UIViewController) {
        guard presentedViewController != nil && presentedViewController!.presentingViewController == self else {
            fatalError()
        }
        dismiss(animated: true, completion: nil)
    }
}

