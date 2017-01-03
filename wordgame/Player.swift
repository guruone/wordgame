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
    
    var highScore: Int {
        return userDefaults.integer(forKey: kHighScore)
    }
    
    init() {
//        checkLeaderBoardScore()
    }
    
    // TODO: ma povodne dorovnavat score podla leader bordu ale nefunguje, pochopitelne
    private func checkLeaderBoardScore() {
        let leaderBoardRequest = GKLeaderboard(players: [GKLocalPlayer.localPlayer()])
        leaderBoardRequest.identifier = LEADER_BOARD_IDENTIFIER
        leaderBoardRequest.loadScores { (_, error: Error?) in
            guard error == nil else {
                #if DEBUG
                    print(#function, error!.localizedDescription)
                #endif
                return
            }
                
            if let leaderBoardLocalPlayerScore = leaderBoardRequest.localPlayerScore {
                let leaderBoardScore = Int(leaderBoardLocalPlayerScore.value)
                
                if self.highScore != leaderBoardScore {
                    self.report(score: self.highScore + leaderBoardScore)
                }
            }
        }
    }
    
    func report(score: Int) {
        let highScore = self.highScore + score
        userDefaults.set(highScore, forKey: kHighScore)
        
        guard PlayerAuthentificator.shared.isAuthenticated() else {
            return
        }
        
        let gkscore = GKScore(leaderboardIdentifier: LEADER_BOARD_IDENTIFIER)
        gkscore.value = Int64(highScore)
        
        GKScore.report([gkscore], withCompletionHandler: { (error: Error?) in
            #if DEBUG
            if nil != error {
                print(error!.localizedDescription)
                
            } else {
                print("score reported: \(gkscore.value)" )
            }
            #endif
        })
    }
    
    func createLeaderBoard(delegateView delegate: GKGameCenterControllerDelegate) -> GKGameCenterViewController {
        let gkVC = GKGameCenterViewController()
        gkVC.gameCenterDelegate = delegate
        gkVC.viewState = .leaderboards
        gkVC.leaderboardIdentifier = LEADER_BOARD_IDENTIFIER
        
        return gkVC
    }
    
    #if DEBUG
    deinit {
        print(#function, self)
    }
    #endif

}

class BonusPoints {
    
    private let userDefaults = UserDefaults.standard
    private let kBonus = "BONUS"
    
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
    
    private var currBonus: Double {
        get {
            return userDefaults.double(forKey: kBonus) == 0 ? 1 : userDefaults.double(forKey: kBonus)
        }
        set {
            userDefaults.set(newValue, forKey: kBonus)
            userDefaults.synchronize()
        }
    }
    
    #if DEBUG
    init() {
        print(#function, self)
    }
    #endif
    
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
    
    func addBonus(_ bonus: Double) {
        currBonus += bonus
    }
    
    func clearBonus() {
        currBonus = 1
    }
    
    #if DEBUG
    deinit {
        print(#function, self)
    }
    #endif
}
