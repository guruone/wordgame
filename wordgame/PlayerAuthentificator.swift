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
    
    var delegate: PlayerAuthentificatorDelagate?
    
    func authentificate() {
        let localPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated {
            delegate?.authentification(success: localPlayer)
            
        } else {
            localPlayer.authenticateHandler = { (viewController: UIViewController?, error: Error?) in
                guard error == nil else {
                    self.delegate?.authentification(failed: error!)
                    return
                }
                
                if viewController != nil {
                    self.delegate?.present(authentification: viewController!)
                    
                } else if localPlayer.isAuthenticated {
                    self.delegate?.authentification(success: localPlayer)
                    
                } else {
                    fatalError()
                }
            }
        }
    }
}
