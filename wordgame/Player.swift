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
    
    private let userDefaults = UserDefaults.standard
    private let kHighScore = "high_score"
    
    func report(score: Int) {
        let highScore = userDefaults.integer(forKey: kHighScore) + score
        userDefaults.set(highScore, forKey: kHighScore)
        
        let gkscore = GKScore(leaderboardIdentifier: LEADER_BOARD_IDENTIFIER)
        gkscore.value = Int64(highScore)
        
        GKScore.report([gkscore], withCompletionHandler: { (error: Error?) in
            if nil != error {
                print(error!.localizedDescription)
                
            } else {
                print("score reported: \(gkscore.value)" )
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

class BonusPoints {
    
    private let BONUS_STEP = 0.1
    private let CNT_MAX_TO_BONUS_STEP = 10
    
    private var cntToNextBonus = 0 {
        didSet {
            if cntToNextBonus == CNT_MAX_TO_BONUS_STEP {
                cntToNextBonus = 1
                currBonus += BONUS_STEP
            }
        }
    }
    
    private var currBonus: Double
    
    var currBonusInPerc: Int {
        return Int(round((self.currBonus - 1 ) * 100.0))
    }
    
    var nextBonusInPerc: Int {
        return Int(round((self.currBonus + BONUS_STEP - 1 ) * 100))
    }
    
    var nextBonusStepRemaining: Int {
        return CNT_MAX_TO_BONUS_STEP - cntToNextBonus
    }
    
    func pointsWithAddedBonus(points: Int) -> Int {
        cntToNextBonus += 1
        return Int(round(Double(points) * currBonus))
    }
    
    convenience init() {
        self.init(withBonus: 1)
    }
    
    init(withBonus bonus: Double) {
        currBonus = bonus
    }
}
