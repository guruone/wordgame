//
//  GameSumaryViewController.swift
//  wordgame
//
//  Created by Marek Mako on 19/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

class GameSumaryViewController: BaseViewController {

    weak var presentingVC: PresentingViewController?
    
    private enum GameSumary {
        case poor, good, excellent
        
        func message() -> String {
            switch self {
            case .poor:
                return "OHH YOUR'RE POOR"
            case .good:
                return "GOOD JOB!"
            case .excellent:
                return "WOOW EXCELLENT!"
            }
        }
        
        func shareMessage() -> String {
            switch self {
            case .poor:
                return "SOME MESSAGE TO SHARE WITH MY POINTS"
            case .good:
                return "SOME MESSAGE TO SHARE WITH MY POINTS"
            case .excellent:
                return "SOME MESSAGE TO SHARE WITH MY POINTS"
            }
        }
        
        func image() -> UIImage {
            switch self {
            case .poor:
                return #imageLiteral(resourceName: "poor-game-sumary")
            case .good:
                return #imageLiteral(resourceName: "good-game-sumary")
            case .excellent:
                return #imageLiteral(resourceName: "excellent-game-sumary")
            }
        }
    }

    /// from segue
    var earnedPoints: Int?
    
    fileprivate var isViewDecorated = false
    
    fileprivate lazy var viewMask: CALayer = {
        let image = UIImage(named: "background")!
        let color = UIColor(patternImage: image)
        let mask = CALayer()
        mask.frame = self.view.bounds
        mask.backgroundColor = color.cgColor
        mask.zPosition = CGFloat.greatestFiniteMagnitude
        return mask
    }()
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var earnedPointsView: UIView!
    
    @IBOutlet weak var earnedPointsLabel: UILabel!

    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var praiseView: UIView!
    
    @IBAction func onDismissClick() {
        presentingVC?.dismissPresentedVC()
    }
    
    @IBAction func onShareClick() {
        
        let gameSumary = resolveGameSumary()
        
        let text = "Wow, I already ended game with \(earnedPoints!) points. My total score is \(Score().highScore(for: Score.Leaderboard.overall)).\nWill you better than me?\n"
        let image = gameSumary.image()
        let url = URL(string: "https://itunes.apple.com/us/app/myapp/id1185310030?ls=1&mt=8")!
        
        let activityVC = UIActivityViewController(activityItems: [text, image, url], applicationActivities: nil)
        
        
        if let popoverVC = activityVC.popoverPresentationController {
            popoverVC.sourceView = view
        }
        
        present(activityVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)

        guard earnedPoints != nil else {
            fatalError()
        }
        
        let gameSumary = resolveGameSumary()
        
        earnedPointsLabel.text = earnedPointsLabel.text?.replacingOccurrences(of: "%@", with: "\(earnedPoints!)")
        messageLabel.text = gameSumary.message()
        categoryImageView.image = gameSumary.image()
        
        view.extSetLetterBlueBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewDecorated {
            isViewDecorated = true
            categoryImageView.layer.zPosition = -1
            view.extAddVerticalLinesFromTop(to: earnedPointsView, offsetFromEdges: 30)
            view.extAddVerticalLinesFromTop(to: praiseView, offsetFromEdges: 3)
            
            view.extRemoveWithAnimation(layer: viewMask)
        }
    }
    
    private func resolveGameSumary() -> GameSumary {
        switch self.earnedPoints! {
        case 0..<1000:
            return GameSumary.poor
        case 1000..<5000:
            return GameSumary.good
        default:
            return GameSumary.excellent
        }
    }
}
