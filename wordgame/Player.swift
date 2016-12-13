//
//  Player.swift
//  wordgame
//
//  Created by Marek Mako on 13/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

fileprivate let LEADER_BOARD_IDENTIFIER = "test"

class Score {
    
    func report(score: Int) {
        let gkscore = GKScore(leaderboardIdentifier: LEADER_BOARD_IDENTIFIER)
        gkscore.value = Int64(score)
        
        GKScore.report([gkscore], withCompletionHandler: { (error: Error?) in
            if nil != error {
                print(error!.localizedDescription)
            }
        })
    }
    
    func createLeaderBoard(delegateView delegate: GKGameCenterControllerDelegate) -> GKGameCenterViewController {
        let gkVC = GKGameCenterViewController()
        gkVC.gameCenterDelegate = delegate
        gkVC.viewState = .leaderboards
        gkVC.leaderboardIdentifier = LEADER_BOARD_IDENTIFIER
        
        return gkVC
    }
}
