//
//  MenuViewController.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class MenuViewController: UIViewController {
    
    fileprivate let playerAuth = PlayerAuthentificator()
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()
    
    fileprivate lazy var gkscore: Score = {
        return Score()
    }()
    
    fileprivate var playerIsAuthetificated = false {
        didSet {
            if presentedViewController != nil { // alert pozri viewDidApear
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            
            if playerIsAuthetificated {
                buttonsEnabled()
                
            } else {
                buttonsDisabled()
            }
        }
    }
    
    @IBOutlet weak var leaderBoardButton: UIButton!
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBOutlet weak var multiPlayerButton: UIButton!

    @IBOutlet weak var gameMenuStackView: UIStackView!
    @IBOutlet weak var leaderBoardView: UIView!
    
    @IBAction func onLeaderBoardClick() {
        let leaderBoardVC = gkscore.createLeaderBoard(delegateView: self)
        present(leaderBoardVC, animated: true, completion: nil)
    }
    
    
    @IBAction func onSinglePlayerClick() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: SinglePlayerViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func onMultiPlayerClick() {
        let vc = multiPlayerMatchMaker.createViewController()
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.extSetLetterBlueBackground()

        buttonsDisabled()
        
        playerAuth.delegate = self
        playerAuth.authentificate()
    }
    
    private func buttonsDisabled() {
        leaderBoardButton.isEnabled = false
        singlePlayerButton.isEnabled = false
        multiPlayerButton.isEnabled = false
    }
    
    private func buttonsEnabled() {
        leaderBoardButton.isEnabled = true
        singlePlayerButton.isEnabled = true
        multiPlayerButton.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: gameMenuStackView, offsetFromEdges: 50)
        view.extAddVerticalLinesFromTop(to: leaderBoardView, offsetFromEdges: 33)
        
        if !playerIsAuthetificated {
            let alert = UIAlertController(title: "Player Authentification", message: "please wait ...", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: PlayerAuthentificatorDelagate
extension MenuViewController: PlayerAuthentificatorDelagate {
    
    func authentification(success player: GKLocalPlayer) {
        playerIsAuthetificated = true
    }
    
    internal func authentification(failed error: Error) {
        //TODO: OSETRIT ERROR PRI AUTHENTIFIKACII
        print(error.localizedDescription)
        playerIsAuthetificated = false
    }

    func present(authentification viewController: UIViewController) {
        func completion() {
            present(viewController, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController!.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
}

// MARK: MatchMakerDelegate
extension MenuViewController: MatchMakerDelegate {
    
    func started(match: GKMatch, with oponent: GKPlayer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: MultiPlayerViewController.self)) as! MultiPlayerViewController
        vc.gkmatch = match
        vc.gkoponent = oponent
        present(vc, animated: true, completion: nil)
    }
    
    func ended(with error: Error?) {
        print(error!.localizedDescription)
    }
}

// MARK: UINavigationControllerDelegate LEADER BOARD DELEGATE
extension MenuViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
