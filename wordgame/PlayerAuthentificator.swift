//
//  PlayerAuthentificator.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GameKit

class PlayerAuthentificator {
    
    static let shared = PlayerAuthentificator()
    
    static let errorNotificationName = Notification.Name("PlayerAuthentificator.errorNotificationName")
    var error: Error?
    
    static let presentVCNotificationName = Notification.Name("PlayerAuthentificator.presentAuthetificationVCNotificationName")
    var authentificationViewController: UIViewController?
    
    static let authentificatedNotificationName = Notification.Name("PlayerAuthentificator.authentificatedLocalPlayerNotificationName")
    var authentificatedLocalPlayer: GKLocalPlayer?
    
    private init() {}
    
    func isAuthenticated() -> Bool {
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
    
    func authentificate() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            NotificationCenter.default.post(name: PlayerAuthentificator.authentificatedNotificationName, object: self)
            
        } else {
            localPlayer.authenticateHandler = { (viewController: UIViewController?, error: Error?) in
                guard error == nil else {
                    self.error = error
                    #if DEBUG
                        print("PlayerAuthentificator.authentificate", error!.localizedDescription)
                    #endif
                    NotificationCenter.default.post(name: PlayerAuthentificator.errorNotificationName, object: self)
                    return
                }
                
                if viewController != nil {
                    self.authentificationViewController = viewController
                    NotificationCenter.default.post(name: PlayerAuthentificator.presentVCNotificationName, object: self)
                    
                    
                } else if localPlayer.isAuthenticated {
                    self.authentificatedLocalPlayer = localPlayer
                    NotificationCenter.default.post(name: PlayerAuthentificator.authentificatedNotificationName, object: self)
                    
                } else {
                    #if DEBUG
                        fatalError()
                    #endif
                }
            }
        }
    }
}
