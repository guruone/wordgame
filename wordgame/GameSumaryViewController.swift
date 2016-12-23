//
//  GameSumaryViewController.swift
//  wordgame
//
//  Created by Marek Mako on 19/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

class GameSumaryViewController: UIViewController {
    
    /// from segue
    var category: WordCategory?
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
    
    @IBOutlet weak var earnedPointsView: UIView!
    
    @IBOutlet weak var earnedPointsLabel: UILabel!

    @IBOutlet weak var categoryImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)

        guard earnedPoints != nil else {
            fatalError()
        }
        guard category != nil else {
            fatalError()
        }
        
        earnedPointsLabel.text = earnedPointsLabel.text?.replacingOccurrences(of: "%@", with: "\(earnedPoints!)")
        categoryImageView.image = category?.gameSumaryImage()
        
        view.extSetLetterBlueBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewDecorated {
            isViewDecorated = true
            view.extAddVerticalLinesFromTop(to: earnedPointsView, offsetFromEdges: 30)
            
            view.extRemoveWithAnimation(layer: viewMask)
        }
    }
}
