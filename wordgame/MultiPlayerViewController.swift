//
//  MultiPlayerViewController.swift
//  wordgame
//
//  Created by Marek Mako on 09/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

protocol GameViewController {
    func setSelectedWordCategory(_ category: WordCategory)
}

enum GameState {
    case waitingToPlayerValue, waitingToWordCategory // game settings
    case waitingToOponentWord // in the game
}

class MultiPlayerViewController: UIViewController, GameViewController, UITextFieldDelegate {
    
    let MAX_TIME_FOR_WORD = 20
    
    fileprivate let myValue = arc4random()
    
    fileprivate let wordRepo = WordRepository()
    
    fileprivate var gameState: GameState = .waitingToPlayerValue
    
    // from segue
    var gkoponent: GKPlayer?
    var gkmatch: GKMatch?
    
    fileprivate var match: Match!
    
    fileprivate var selectedCategory: WordCategory? {
        didSet {
            // TODO: zobrazit nazov kategorie
        }
    }
    
    fileprivate var oponentWord: String? {
        didSet {
            oponentWordLabel.text = oponentWord!
            
            let lastChar = "\(oponentWord!.characters.last!)"
            currentWordTextField.text = lastChar
            
            pointsForCurrentWord = Int(wordRepo.findPoints(forCategory: selectedCategory!, startsWith: lastChar).points)
            
            // MARK: START WORD TIMER
            timeRemaining = MAX_TIME_FOR_WORD
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer: Timer) in
                if self.timeRemaining! == 0 {
                    // MARK: GAME OVER
                    timer.invalidate()
                    self.sendGameOverWithPoints()
                    
                } else {
                    self.timeRemaining! -= 1
                }
            })
        }
    }
    
    fileprivate var timer: Timer?
    
    private var timeRemaining: Int? {
        didSet {
            timeLabel.text = "\(timeRemaining!) s"
        }
    }
    
    fileprivate var pointsForCurrentWord: Int? {
        didSet {
            // TODO: zobrazit body ktore je mozne ziskat za aktualne slovo
        }
    }
    
    fileprivate var score: Int? {
        didSet {
            scoreLabel.text = "SCORE: \(score!)"
            sendScore()
        }
    }
    
    fileprivate var oponentScore: Int? {
        didSet {
            oponentScoreLabel.text = "SCORE: \(oponentScore!)"
        }
    }
    
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
            self.gkmatch?.disconnect()
        })
    }
    
    // MARK: GameViewController
    internal func setSelectedWordCategory(_ category: WordCategory) {
        selectedCategory = category
        sendSelectedWordCategory()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let lastChar = oponentWord!.characters.last!
        let firstChar = textField.text!.characters.first!
        
        // MARK: VALIDACIA ZADANEHO SLOVA
        guard lastChar == firstChar else {
            presentCharacterAreNotEqual(leftchar: "\(lastChar)", rightChar: "\(firstChar)")
            return false
        }
        guard true == wordRepo.wordExists(for: selectedCategory!, word: textField.text!) else {
            presentWordDoesNotExists(textField.text!)
            return false
        }
        
        sendCurrentWord()
        
        return true
    }
}

// MARK: LIFECYCLE
extension MultiPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard gkoponent != nil, gkmatch != nil else {
            fatalError()
        }
        match = Match(from: gkmatch!, with: gkoponent!)
        match.delegate = self
        
        currentWordTextField.delegate = self
        currentWordTextField.autocorrectionType = .no
        
        oponentNameLabel.text = gkoponent?.alias
        score = 0
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
        
        if gameState == .waitingToPlayerValue {
            sendPlayerValue()
        }
    }
}

// MARK: MatchDelegate
extension MultiPlayerViewController: MatchDelegate {
    
    func ended() {
        DispatchQueue.main.async {
            self.presentGameOver()
        }
    }
    
    func sendPlayerValue() {
        presentGameInit {
            self.match.sendPlayerValue(self.myValue)
        }
    }
    
    func received(playerValue value: UInt32) {
        func completion() {
            if value > myValue {
                presentChooseCategory()
                gameState = .waitingToOponentWord
                
            } else {
                gameState = .waitingToWordCategory
                presentWaitingForCategoryFromOponent()
            }
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
        
    }
    
    func sendSelectedWordCategory() {
        presentWaitingForOponentWord {
            self.match.sendSelectedCategory(self.selectedCategory!)
        }
    }
    
    func received(selectedCategory value: WordCategory) {
        func completion() {
            gameState = .waitingToOponentWord
            // MARK: PRIJAL SOM KATEGORIU OD OPONENTA, NASTAVUJEM RANDOM SLOVO PRE KATEGORIU
            selectedCategory = value
            setRandomWordFromSelectedCategory()
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
    
    func sendCurrentWord() {
        presentWaitingForOponentWord {
            self.timer?.invalidate()
            self.score! += self.pointsForCurrentWord!
            self.match.sendWord(self.currentWordTextField.text!)
        }
    }
    
    func received(oponentWord word: String) {
        func completion() {
            oponentWord = word
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
    
    func sendScore() {
        match.sendPoints(score!)
    }
    
    func recieved(oponentPoints points: Int) {
        oponentScore = points
    }
    
    /// regularna vyhra
    func sendGameOverWithPoints() {
        match.sendGameOver(points: score!)
        match.cancelFromUser()
        presentLoose()
    }
    
    func received(gameOverWithOponentPoints points: Int) {
        match.cancelFromUser()
        presentWin()
    }
}

// MARK: Alerts
extension MultiPlayerViewController {
    
    func presentGameInit(completion: @escaping () -> Void) {
        let vc = UIAlertController(title: "Hra sa inicializuje", message: "please wait ...", preferredStyle: .alert)
        present(vc, animated: true, completion: completion)
    }
    
    func presentWaitingForCategoryFromOponent() {
        let vc = UIAlertController(title: "Oponent vybera kategoriu", message: "please wait ...", preferredStyle: .alert)
        present(vc, animated: true, completion: nil)
    }
    
    func presentChooseCategory() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChooseWordCategoryViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    func presentWaitingForOponentWord(completion: @escaping () -> Void) {
        let vc = UIAlertController(title: "Oponent typing word", message: "please wait ...", preferredStyle: .alert)
        present(vc, animated: true, completion: completion)
    }
    
    func presentCharacterAreNotEqual(leftchar: String, rightChar: String) {
        let alertVC = UIAlertController(title: "Chyba", message: "\(leftchar) != \(rightChar)", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func presentWordDoesNotExists(_ word: String) {
        let alertVC = UIAlertController(title: "\(word) som nenasiel.", message: "Skus ine", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentLoose() {
        func completion() {
            let alertVC = UIAlertController(title: "🐢 Prehral ši baran 🐢", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
    
    func presentWin() {
        func completion() {
            let alertVC = UIAlertController(title: "🐭 Vyhral ši dilino 🐭", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
    
    func presentGameOver() {
        func completion() {
            let alertVC = UIAlertController(title: "Game Over", message: "😳 🐓 ta nejde 🐓 😳", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
}

extension MultiPlayerViewController {
    
    fileprivate func setRandomWordFromSelectedCategory() {
        oponentWord = wordRepo.findRandomOne(for: selectedCategory!).value(forKey: "name") as? String
    }
}
