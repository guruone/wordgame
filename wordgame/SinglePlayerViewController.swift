//
//  SinglePlayerViewController.swift
//  wordgame
//
//  Created by Marek Mako on 09/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit


class SinglePlayerViewController: UIViewController {
    
    @IBOutlet weak var scoreAndTimeView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var oponentWordLabel: UILabel!
    @IBOutlet weak var currentWordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        currentWordTextField.autocorrectionType = .no
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addCenterRound()
        addVerticalLinesFromTopToScoreAndTimeView()
        addBottomBorder(scoreLabel)
        addBottomBorder(oponentWordLabel)
        addBorderToScoreAndTimeView()
        addBorder(wordView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: GRAFIKA
extension SinglePlayerViewController {
    
    func addVerticalLinesFromTopToScoreAndTimeView() {
        let leftLine = CALayer()
        leftLine.frame = CGRect(x: wordView.frame.origin.x + 20,
                                y: 0,
                                width: 5,
                                height: wordView.frame.origin.y)
        leftLine.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(leftLine)
        
        let rightLine = CALayer()
        rightLine.frame = CGRect(x: wordView.frame.origin.x + wordView.frame.width - 25,
                                 y: 0,
                                 width: 5,
                                 height: wordView.frame.origin.y)
        rightLine.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(rightLine)
    }
    
    fileprivate func addCenterRound() {
        let round = CALayer()
        round.frame = CGRect(x: 0,
                             y: view.center.y - view.frame.width / 2,
                             width: view.frame.width,
                             height: view.frame.width)
        round.backgroundColor = UIColor(red: 167/255, green: 224/255, blue: 165/255, alpha: 1).cgColor
        round.zPosition = -1
        round.cornerRadius = view.frame.width / 2
        view.layer.addSublayer(round)
    }
    
    fileprivate func addBorderToScoreAndTimeView() {
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 5,
                                  height: scoreAndTimeView.frame.height)
        leftBorder.backgroundColor = UIColor.white.cgColor
        scoreAndTimeView.layer.addSublayer(leftBorder)
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0,
                                 y: 0,
                                 width: scoreAndTimeView.frame.width,
                                 height: 5)
        topBorder.backgroundColor = UIColor.white.cgColor
        scoreAndTimeView.layer.addSublayer(topBorder)
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: scoreAndTimeView.frame.width,
                                   y: 0,
                                   width: 5,
                                   height: scoreAndTimeView.frame.height)
        rightBorder.backgroundColor = UIColor.white.cgColor
        scoreAndTimeView.layer.addSublayer(rightBorder)
    }
    
    fileprivate func addBorder(_ view: UIView) {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 5
    }
    
    fileprivate func addBottomBorder(_ view: UIView) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0,
                                    y: view.frame.height,
                                    width: view.frame.width,
                                    height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        
        view.layer.addSublayer(bottomBorder)
    }
}
