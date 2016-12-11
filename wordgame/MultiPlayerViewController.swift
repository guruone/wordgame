//
//  MultiPlayerViewController.swift
//  wordgame
//
//  Created by Marek Mako on 09/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class MultiPlayerViewController: UIViewController {
    
    // from segue
    var oponent: GKPlayer?
    var match: GKMatch?
    
    @IBOutlet weak var oponentLabel: UILabel!
    @IBOutlet weak var oponentScoreAndTimeView: UIView!
    @IBOutlet weak var oponentNameLabel: UILabel!
    @IBOutlet weak var oponentScoreLabel: UILabel!
    
    @IBOutlet weak var scoreAndTimeView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var oponentWordLabel: UILabel!
    @IBOutlet weak var currentWordTextField: UITextField!
    
    @IBAction func onDismissClick() {
        dismiss(animated: true, completion: {
            // TODO: MATCH DISAPEAR/DISCONNECT
            self.match?.disconnect()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard oponent != nil, match != nil else {
            fatalError()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: oponentScoreAndTimeView, offsetFromEdges: 10)
        view.extAddVerticalLinesFromTop(to: wordView, offsetFromEdges: 20)
        scoreLabel.extAddBottomBorder()
        oponentWordLabel.extAddBottomBorder()
        oponentNameLabel.extAddBottomBorder()
        scoreAndTimeView.extAddLeftTopRighBorder()
        oponentLabel.extAddLeftTopRighBorder()
        oponentScoreAndTimeView.extAddBorder()
        wordView.extAddBorder()
    }
}
