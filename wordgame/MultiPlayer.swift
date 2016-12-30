//
//  MultiPlayer.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import Foundation
import GameKit
import CoreData

// MARK: MATCHMAKER

protocol MatchInviteDelegate {
    /// pri notifikacii volam MatchMaker:createViewController:forInvite
    func matchDidInvite(_ invite: GKInvite)
}

class MatchInviteListener: NSObject, GKLocalPlayerListener {
    
    static let shared = MatchInviteListener()
    
    var delegate: MatchInviteDelegate?
    
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        print("player:didAccept:invite")
        delegate?.matchDidInvite(invite)
    }
    
    private override init() {
        print("init MatchInviteListener")
    }

    deinit {
        print("deinit MatchInviteListener")
    }
}

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
    
    func createViewController(forInvite invite: GKInvite) -> GKMatchmakerViewController {
        let matchmakerVC = GKMatchmakerViewController(invite: invite)
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

// MARK: MATCH

protocol MatchDelegate {
    func ended()
    
    func received(playerValue value: UInt32)
    func received(selectedCategory value: WordCategory)
    func received(gameOverWithOponentPoints points: Int)
    func received(oponentWord word: String)
    func recieved(oponentPoints points: Int)
}

class Match: NSObject {
    
    fileprivate var gkMatchIsActive = true
    fileprivate let gkMatch: GKMatch
    fileprivate let gkOponent: GKPlayer
    
    var delegate: MatchDelegate?
    
    init(from gkMatch: GKMatch, with gkOponent: GKPlayer) {
        self.gkMatch = gkMatch
        self.gkOponent = gkOponent
        
        super.init()
        
        self.gkMatch.delegate = self
    }
    
    func cancelFromUser() {
        gkMatchIsActive = false
        gkMatch.disconnect()
    }
    
    fileprivate func end() {
        if gkMatchIsActive {
            gkMatchIsActive = false
            gkMatch.disconnect()
            delegate?.ended()
        }
    }
}

// MARK: GKMatchDelegate
extension Match: GKMatchDelegate {
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        let message = MatchMessage.from(data: data)
        received(message: message)
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        end()
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        end()
    }
}

// MARK: MESSENGING

class MatchMessage: NSObject, NSCoding {
    
    enum MessageType: Int {
        case playerValue, selectedCategory, gameOver, word, totalPoints
    }
    
    var type: MessageType?
    
    var message: String?
    
    class func from(data: Data) -> MatchMessage {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! MatchMessage
    }
    
    init(type: MessageType, message: String = "") {
        self.type = type
        self.message = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        message = aDecoder.decodeObject(forKey: "message") as? String
        type = MessageType(rawValue: aDecoder.decodeObject(forKey: "type_raw") as! Int)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(message, forKey: "message")
        aCoder.encode(type?.rawValue, forKey: "type_raw")
    }
    
    func asData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

extension Match {
    
    func sendPlayerValue(_ value: UInt32) {
        let message = MatchMessage(type: .playerValue, message: "\(value)")
        send(message)
    }
    
    func sendSelectedCategory(_ value: WordCategory) {
        let message = MatchMessage(type: .selectedCategory, message: value.rawValue)
        send(message)
    }
    
    func sendGameOver(points: Int) {
        let message = MatchMessage(type: .gameOver, message: "\(points)")
        send(message)
    }
    
    func sendWord(_ word: String) {
        let message = MatchMessage(type: .word, message: "\(word)")
        send(message)
    }
    
    func sendPoints(_ points: Int) {
        let message = MatchMessage(type: .totalPoints, message: "\(points)")
        send(message)
    }
    
    fileprivate func send(_ message: MatchMessage) {
        try! self.gkMatch.send(message.asData(), to: [gkOponent], dataMode: .reliable)
    }
    
    fileprivate func received(message: MatchMessage) {
        switch message.type! {
        case .playerValue:
            delegate?.received(playerValue: UInt32(message.message!)!)
            break
        case .selectedCategory:
            let selectedCategory = WordCategory(rawValue: message.message!)!
            delegate?.received(selectedCategory: selectedCategory)
            break
        case .gameOver:
            let oponentPoints = Int(message.message!)!
            delegate?.received(gameOverWithOponentPoints: oponentPoints)
            break
        case .word:
            let oponentWord = message.message!
            delegate?.received(oponentWord: oponentWord)
            break
        case .totalPoints:
            let oponentPoints = Int(message.message!)!
            delegate?.recieved(oponentPoints: oponentPoints)
        }
    }
}



