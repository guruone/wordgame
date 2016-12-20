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
    
    @IBOutlet weak var earnedPointsView: UIView!
    
    @IBOutlet weak var earnedPointsLabel: UILabel!

    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBAction func onDismissClick(_ sender: Any) {
        let presentingViewController = self.presentingViewController!
        
        dismiss(animated: true, completion: {
            presentingViewController.dismiss(animated: true, completion: nil)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        view.extAddVerticalLinesFromTop(to: earnedPointsView, offsetFromEdges: 30)
    }
}
