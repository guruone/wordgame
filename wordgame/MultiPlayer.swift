//
//  MultiPlayer.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GameKit

protocol MatchMakerDelegate {
    func started(match: GKMatch, with oponent: GKPlayer)
    func ended(with error: Error?)
}

class MatchMaker: NSObject {
    
    var delegate: MatchMakerDelegate?
    
    func createViewController() -> GKMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        let matchmakerVC = GKMatchmakerViewController(matchRequest: request)
        matchmakerVC?.matchmakerDelegate = self
        return matchmakerVC!
    }
}

extension MatchMaker: GKMatchmakerViewControllerDelegate {
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: {
            self.delegate?.ended(with: error)
        })
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true, completion: {
            
            // MARK: LOOKUP FOR PLAYERS
            let playersId = match.players.map({ $0.playerID }) as! [String]
            
            GKPlayer.loadPlayers(forIdentifiers: playersId, withCompletionHandler: { (players: [GKPlayer]?, error: Error?) in
                guard error == nil else {
                    viewController.dismiss(animated: true, completion: {
                        self.delegate?.ended(with: error)
                    })
                    return
                }
                
                // MARK: MATCH STARTED
                GKMatchmaker.shared().finishMatchmaking(for: match)
                self.delegate?.started(match: match, with: players!.first!)
            })
        })
    }
}
