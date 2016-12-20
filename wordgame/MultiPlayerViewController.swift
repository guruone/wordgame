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
    
    fileprivate let gkScore = Score()
    
    fileprivate let wordRepo = WordRepository()
    
    fileprivate let bonus = BonusPoints.shared
    
    /// uz pouzite slova su zakazane
    fileprivate var forbiddenWords = [String]()
    
    fileprivate var gameState: GameState = .waitingToPlayerValue
    
    // from segue
    var gkoponent: GKPlayer?
    var gkmatch: GKMatch?
    
    fileprivate var match: Match!
    
    fileprivate var selectedCategory: WordCategory? {
        didSet {
            categoryLabel.text = "CATEGORY: \(selectedCategory!.rawValue)"
        }
    }
    
    fileprivate var oponentWord: String? {
        didSet {
            oponentWordLabel.text = oponentWord!
            
            forbiddenWords.append(oponentWord!)
            
            let lastChar = "\(oponentWord!.characters.last!)"
            currentWordTextField.text = lastChar
            
            let wordPoints = Int(wordRepo.findPoints(forCategory: selectedCategory!, startsWith: lastChar).points)
            pointsForCurrentWord = bonus.pointsWithAddedBonus(points: wordPoints)
            
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
    
    fileprivate var timeRemaining: Int? {
        didSet {
            timeLabel.text = "TIME: \(timeRemaining!) s"
        }
    }
    
    fileprivate var pointsForCurrentWord: Int? {
        didSet {
            pointForCurrentWordLabel.text = "\(pointsForCurrentWord!)"
            
            let bonusInPerc = bonus.currBonusInPerc
            bonusLabel.text = "BONUS \(bonusInPerc)%"
            
            let wordsToNextBonus = bonus.nextBonusStepRemaining
            let nextBonusInPerc = bonus.nextBonusInPerc
            
            bonusInfoLabel.text = "\(wordsToNextBonus) TO \(nextBonusInPerc)%"
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
    
    @IBOutlet weak var categoryAndBonusView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var bonusInfoLabel: UILabel!
    
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
    @IBOutlet weak var pointForCurrentWordLabel: UILabel!
    
    @IBAction func onDismissClick() {
        bonus.clearBonus()
        timer?.invalidate()
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
        guard textField.text?.characters.first != nil else {
            return false
        }
        
        guard forbiddenWords.contains(textField.text!) == false else {
            presentAlreadyUsed(word: textField.text!)
            return false
        }
        
        
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
        timeRemaining = MAX_TIME_FOR_WORD
        oponentScore = 0
        score = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: oponentScoreAndTimeView, offsetFromEdges: 10)
        view.extAddVerticalLinesFromTop(to: wordView, offsetFromEdges: 20)
        scoreLabel.extAddBorder([.bottom(width: 1)])
        oponentWordLabel.extAddBorder([.bottom(width: 1)])
        oponentNameLabel.extAddBorder([.bottom(width: 1)])
        scoreAndTimeView.extAddBorder([.left(width: 5), .top(width: 5), .right(width: 5)])
        oponentLabel.extAddBorder([.left(width: 5), .top(width: 5), .right(width: 5)])
        oponentScoreAndTimeView.extAddBorder([.all(width: 5)])
        wordView.extAddBorder([.all(width: 5)])
        
        categoryAndBonusView.extAddBorder([.all(width: 5)])
        categoryLabel.extAddBorder([.bottom(width: 1)])
        bonusLabel.extAddBorder([.right(width: 0.5)])
        bonusInfoLabel.extAddBorder([.left(width: 0.5)])
        
        pointForCurrentWordLabel.extAddBorder([.top(width: 5), .right(width: 5)])
        
        if gameState == .waitingToPlayerValue {
            sendPlayerValue()
        }
    }
}

// MARK: MatchDelegate
extension MultiPlayerViewController: MatchDelegate {
    
    func ended() {
        timer?.invalidate()
        DispatchQueue.main.async {
            let totalScore = self.oponentScore! + self.score!
            self.gkScore.report(score: totalScore)
            
            self.presentGameOver(yourPoints: self.score!, oponentPoints: self.oponentScore!)
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
            self.forbiddenWords.append(self.currentWordTextField.text!)
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
        let totalScore = points + score!
        gkScore.report(score: totalScore)
        
        match.cancelFromUser()
        presentWin(yourPoints: score!, oponentPoints: points)
    }
}

// MARK: Alerts
extension MultiPlayerViewController {
    
    func presentGameInit(completion: @escaping () -> Void) {
        let vc = UIAlertController(title: "Hra sa inicializuje", message: "please wait ...", preferredStyle: .actionSheet)
        present(vc, animated: true, completion: completion)
    }
    
    func presentWaitingForCategoryFromOponent() {
        let vc = UIAlertController(title: "Oponent vybera kategoriu", message: "please wait ...", preferredStyle: .actionSheet)
        present(vc, animated: true, completion: nil)
    }
    
    func presentChooseCategory() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChooseWordCategoryViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    func presentWaitingForOponentWord(completion: @escaping () -> Void) {
        let vc = UIAlertController(title: "Oponent typing word", message: "please wait ...", preferredStyle: .actionSheet)
        present(vc, animated: true, completion: completion)
    }
    
    func presentAlreadyUsed(word: String) {
        let alertVC = UIAlertController(title: "Slovo \(word) uz bolo pouzite", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func presentCharacterAreNotEqual(leftchar: String, rightChar: String) {
        let alertVC = UIAlertController(title: "Chyba", message: "\(leftchar) != \(rightChar)", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func presentWordDoesNotExists(_ word: String) {
        let alertVC = UIAlertController(title: "\(word) som nenasiel.", message: "Skus ine", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentLoose() {
        func completion() {
            bonus.clearBonus()
            let alertVC = UIAlertController(title: "🐢 Prehral ši baran 🐢", message: nil, preferredStyle: .actionSheet)
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
    
    func presentWin(yourPoints: Int, oponentPoints: Int) {
        func completion() {
            bonus.clearBonus()
            let alertVC = UIAlertController(title: "Vyhral si \(yourPoints + oponentPoints) bodov", message: "na tvoje konto bolo pripocitanych \(yourPoints) + \(oponentPoints) oponentovych bodov", preferredStyle: .actionSheet)
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
    
    func presentGameOver(yourPoints: Int, oponentPoints: Int) {
        func completion() {
            bonus.clearBonus()
            let alertVC = UIAlertController(title: "Game Over \(yourPoints + oponentPoints) bodov", message: "na tvoje konto bolo pripocitanych \(yourPoints) + \(oponentPoints) oponentovych bodov", preferredStyle: .actionSheet)
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
