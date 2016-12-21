//
//  PlayerAuthentificator.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GameKit

protocol PlayerAuthentificatorDelagate {
    func authentification(failed error: Error)
    func authentification(success player: GKLocalPlayer)
    func present(authentification viewController: UIViewController)
}

class PlayerAuthentificator {
    
    static let presentVCNotificationName = Notification.Name("presentAuthetificationVCNotificationName")
    var authentificationViewController: UIViewController?
    
    static let authentificatedNotificationName = Notification.Name("authentificatedLocalPlayerNotificationName")
    var authentificatedLocalPlayer: GKLocalPlayer?
    
    var delegate: PlayerAuthentificatorDelagate?
    
    func authentificate() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            delegate?.authentification(success: localPlayer)
            NotificationCenter.default.post(name: PlayerAuthentificator.authentificatedNotificationName, object: self)
            
        } else {
            localPlayer.authenticateHandler = { (viewController: UIViewController?, error: Error?) in
                guard error == nil else {
                    self.delegate?.authentification(failed: error!)
                    return
                }
                
                if viewController != nil {
                    self.delegate?.present(authentification: viewController!)
                    self.authentificationViewController = viewController
                    NotificationCenter.default.post(name: PlayerAuthentificator.presentVCNotificationName, object: self)
                    
                    
                } else if localPlayer.isAuthenticated {
                    self.delegate?.authentification(success: localPlayer)
                    self.authentificatedLocalPlayer = localPlayer
                    NotificationCenter.default.post(name: PlayerAuthentificator.authentificatedNotificationName, object: self)
                    
                } else {
                    fatalError()
                }
            }
        }
    }
}
