//
//  SinglePlayerViewController.swift
//  wordgame
//
//  Created by Marek Mako on 09/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit


class SinglePlayerViewController: UIViewController, GameViewController {
    
    let MAX_TIME_FOR_WORD = 20
    
    fileprivate let gkscore = Score()
    
    fileprivate let wordRepo = WordRepository()
    
    fileprivate let bonus = BonusPoints()
    
    /// uz pouzite slova su zakazane
    fileprivate var forbiddenWords = [String]()
    
    fileprivate var gameState: GameState = .waitingToWordCategory
    
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
            
            print("points:", wordPoints, pointsForCurrentWord!)
            
            // MARK: START WORD TIMER
            timeRemaining = MAX_TIME_FOR_WORD
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer: Timer) in
                if self.timeRemaining! == 0 {
                    // MARK: GAME OVER
                    timer.invalidate()
                    self.gameOver()
                    
                } else {
                    self.timeRemaining! -= 1
                }
            })
        }
    }
    
    fileprivate var timer: Timer?
    
    private var timeRemaining: Int? {
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
        }
    }
    
    
    
    
    @IBOutlet weak var categoryAndBonusView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var bonusInfoLabel: UILabel!
    
    @IBOutlet weak var scoreAndTimeView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var wordView: UIView!
    @IBOutlet weak var oponentWordLabel: UILabel!
    @IBOutlet weak var currentWordTextField: UITextField!
    @IBOutlet weak var pointForCurrentWordLabel: UILabel!
    
    @IBAction func onDismissClick() {
        timer?.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHintClick() {
        let lastChar = "\(oponentWord!.characters.last!)"
        currentWordTextField.text = wordRepo.findRandomOne(for: selectedCategory!, startWith: lastChar).value(forKey: "name") as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWordTextField.autocorrectionType = .no
        currentWordTextField.delegate = self
        
        timeRemaining = MAX_TIME_FOR_WORD
        score = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // GRAFIKA
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: wordView, offsetFromEdges: 20)
        view.extAddVerticalLinesFromTop(to: categoryAndBonusView, offsetFromEdges: 20)
        scoreLabel.extAddBorder([.bottom(width: 1)])
        oponentWordLabel.extAddBorder([.bottom(width: 1)])
        scoreAndTimeView.extAddBorder([.left(width: 5), .top(width: 5), .right(width: 5)])
        wordView.extAddBorder([.all(width: 5)])
        
        categoryAndBonusView.extAddBorder([.all(width: 5)])
        categoryLabel.extAddBorder([.bottom(width: 1)])
        bonusLabel.extAddBorder([.right(width: 0.5)])
        bonusInfoLabel.extAddBorder([.left(width: 0.5)])
        
        pointForCurrentWordLabel.extAddBorder([.top(width: 5), .right(width: 5)])
        
        if gameState == .waitingToWordCategory {
            gameState = .waitingToOponentWord
            presentChooseCategory()
        }
    }
    
    func setSelectedWordCategory(_ category: WordCategory) {
        selectedCategory = category
        oponentWord = wordRepo.findRandomOne(for: selectedCategory!).value(forKey: "name") as? String
    }
    
    fileprivate func gameOver() {
        gkscore.report(score: score!)
        presentGameOver(yourPoints: score!)
    }
}

extension SinglePlayerViewController: UITextFieldDelegate {
    
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
        
        self.score! += self.pointsForCurrentWord!
        oponentWord = textField.text
        
        return true
    }
}

// MARK: ALERTS
extension SinglePlayerViewController {
    
    func presentChooseCategory() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChooseWordCategoryViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    func presentAlreadyUsed(word: String) {
        let alertVC = UIAlertController(title: "Slovo \(word) uz bolo pouzite", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
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
    
    func presentGameOver(yourPoints: Int) {
        func completion() {
            let alertVC = UIAlertController(title: "Game Over", message: "na tvoje konto bolo pripocitanych \(yourPoints) bodov", preferredStyle: .alert)
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
