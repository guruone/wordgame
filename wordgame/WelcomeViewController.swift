//
//  WelcomeViewController.swift
//  wordgame
//
//  Created by Marek Mako on 23/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class WelcomeViewController: UIViewController {
    
    fileprivate lazy var multiPlayerMatchMaker: MatchMaker = {
        let maker = MatchMaker()
        maker.delegate = self
        return maker
    }()
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewBehingImageView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    fileprivate lazy var viewMask: CALayer = {
        let image = UIImage(named: "background")!
        let color = UIColor(patternImage: image)
        let mask = CALayer()
        mask.frame = self.view.bounds
        mask.backgroundColor = color.cgColor
        mask.zPosition = CGFloat.greatestFiniteMagnitude
        return mask
    }()
    
    fileprivate var playerIsAuthetificated = false {
        didSet {
            if presentedViewController != nil { // alert pozri viewDidApear
                presentedViewController?.dismiss(animated: true, completion: nil)
            }
            
            if playerIsAuthetificated {
                startButton.isEnabled = true
                
            } else {
                startButton.isEnabled = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(authentificationSuccess(notification:)), name: PlayerAuthentificator.authentificatedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAuthViewController(notification:)), name: PlayerAuthentificator.presentVCNotificationName, object: nil)
        
        view.layer.addSublayer(viewMask)
        
        view.extSetLetterBlueBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !playerIsAuthetificated {
            let alert = UIAlertController(title: "Player Authentification", message: "please wait ...", preferredStyle: .actionSheet)
            present(alert, animated: true, completion: nil)
        }
        
        view.extAddCenterRound()
        viewBehingImageView.extAddBorder([.all(width: 5)])
        startButton.extAddBorder([.all(width: 5)])
        decorateWithVerticalLines()
        
        view.extRemoveWithAnimation(layer: viewMask)
    }
}

// MARK: PlayerAuthentificatorDelagate
extension WelcomeViewController: PlayerAuthentificatorDelagate {
    
    func authentificationSuccess(notification: Notification) {
        if let playerAuth = notification.object as? PlayerAuthentificator {
            authentification(success: playerAuth.authentificatedLocalPlayer!)
        }
    }
    
    func authentification(success player: GKLocalPlayer) {
        playerIsAuthetificated = true
        player.unregisterAllListeners()
        let listener = MatchInviteListener()
        listener.delegate = self
        player.register(listener)
    }
    
    internal func authentification(failed error: Error) {
        //TODO: OSETRIT ERROR PRI AUTHENTIFIKACII
        print(error.localizedDescription)
        playerIsAuthetificated = false
    }
    
    func presentAuthViewController(notification: Notification) {
        if let authPlayer = notification.object as? PlayerAuthentificator {
            present(authentification: authPlayer.authentificationViewController!)
        }
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

// MARK: MatchInviteDelegate
extension WelcomeViewController: MatchInviteDelegate {
    
    func matchDidInvite(_ invite: GKInvite) {
        print("matchDidInvite")
        let vc = multiPlayerMatchMaker.createViewController(forInvite: invite)
        present(vc, animated: true, completion: nil)
    }
}

// MARK: MatchMakerDelegate
extension WelcomeViewController: MatchMakerDelegate {
    
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

// MARK: GRAFIKA
extension WelcomeViewController {
    
    fileprivate func decorateWithVerticalLines() {
        // FROM TOP to stackView
        addLinesFromTopToStackView()
        
        // FROM viewBehingImageView to startButton
        addLinesFromViewBehindImageViewToStartButton()
    }
    
    private func addLinesFromTopToStackView() {
        let xFromLeft = stackView.frame.origin.x + 30
        let yFromLeft: CGFloat = 0
    
        let xToLeft = xFromLeft
        let yToLeft = stackView.frame.origin.y
        
        let xFromRight = stackView.bounds.width + stackView.frame.origin.x - 30
        let yFromRight: CGFloat = 0
        
        let xToRight = xFromRight
        let yToRight = stackView.frame.origin.y
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xFromLeft, y: yFromLeft))
        path.addLine(to: CGPoint(x: xToLeft, y: yToLeft))
        
        path.move(to: CGPoint(x: xFromRight, y: yFromRight))
        path.addLine(to: CGPoint(x: xToRight, y: yToRight))
        
        // RENDER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        
        view.layer.addSublayer(shapeLayer)
    }
    
    private func addLinesFromViewBehindImageViewToStartButton() {
        let xFromLeft: CGFloat = 0
        let xToLeft = startButton.frame.origin.x
        
        let yFromLeft = viewBehingImageView.bounds.height
        let yToLeft = startButton.frame.origin.y
        
        let xFromRight = viewBehingImageView.bounds.width
        let xToRight = startButton.frame.origin.x + startButton.bounds.width
        
        let yFromRight = viewBehingImageView.bounds.height
        let yToRight = startButton.frame.origin.y
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xFromLeft + 5, y: yFromLeft - 1))
        path.addLine(to: CGPoint(x: xToLeft + 1, y: yToLeft + 1))
        
        path.move(to: CGPoint(x: xFromRight - 5, y: yFromRight - 1))
        path.addLine(to: CGPoint(x: xToRight - 1, y: yToRight + 1))
        
        // RENDER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        
        stackView.layer.addSublayer(shapeLayer)
    }
}
