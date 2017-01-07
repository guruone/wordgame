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
    case gameOver
}

class MultiPlayerViewController: UIViewController, GameViewController, UITextFieldDelegate {
    
    let MAX_TIME_FOR_WORD = 10
    
    weak var presentingVC: PresentingViewController?
    
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
    
    fileprivate let myValue = arc4random()
    
    fileprivate var recievedPlayerValueTimer: Timer?
    
    fileprivate let gkScore = Score()
    
    fileprivate let wordRepo = WordRepository()
    
    fileprivate let bonus = BonusPoints()
    
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
        self.gkmatch?.disconnect()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
        
        view.layer.addSublayer(viewMask)
        
        view.extSetLetterBlueBackground()
        
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
        
        guard gameState != .gameOver else {
            return
        }
        
        if !isViewDecorated {
            isViewDecorated = true
            // GRAFIKA
            view.extAddCenterRound()
            view.extAddVerticalLinesFromTop(to: oponentScoreAndTimeView, offsetFromEdges: 10)
            view.extAddVerticalLinesFromTop(to: wordView, offsetFromEdges: 20)
            scoreLabel.extAddBorder([.bottom(width: 1)])
            oponentWordLabel.extAddBorder([.bottom(width: 1)])
            oponentNameLabel.extAddBorder([.bottom(width: 1)])
            scoreAndTimeView.extAddBorder([.all(width: 5)])
            view.extAddVerticalLinesFromTop(to: scoreAndTimeView, offsetFromEdges: 10)
            oponentLabel.extAddBorder([.left(width: 5), .top(width: 5), .right(width: 5)])
            oponentScoreAndTimeView.extAddBorder([.all(width: 5)])
            
            
            
            wordView.extAddBorder([.left(width: 5), .right(width: 5), .bottom(width: 5), .top(width: 2.5)])
            categoryAndBonusView.extAddBorder([.left(width: 5), .top(width: 5), .right(width: 5), .bottom(width: 2.5)])
            categoryLabel.extAddBorder([.right(width: 5)])
            bonusLabel.extAddBorder([.right(width: 5)])
            
            pointForCurrentWordLabel.extAddBorder([.top(width: 5), .right(width: 5)])
            
            view.extRemoveWithAnimation(layer: viewMask)
        }
        
        if gameState == .waitingToPlayerValue {
            sendPlayerValue()
        }
        
        recievedPlayerValueTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(sendResendPlayerValue), userInfo: nil, repeats: true)
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
        recievedPlayerValueTimer?.invalidate()
        recievedPlayerValueTimer = nil
        
        tryDismissAlertAndPresent {
            if value > self.myValue {
                self.presentChooseCategory()
                self.gameState = .waitingToOponentWord
                
            } else {
                self.gameState = .waitingToWordCategory
                self.presentWaitingForCategoryFromOponent()
            }
        }
        
    }
    
    func sendSelectedWordCategory() {
        presentWaitingForOponentWord {
            self.match.sendSelectedCategory(self.selectedCategory!)
        }
    }
    
    func received(selectedCategory value: WordCategory) {
        recievedPlayerValueTimer?.invalidate()
        recievedPlayerValueTimer = nil
        
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
    
    func sendResendPlayerValue() {
        if gameState == .waitingToPlayerValue {
            match.sendResendPlayerValue()
        } else {
            recievedPlayerValueTimer?.invalidate()
            recievedPlayerValueTimer = nil
        }
        
    }
    
    func recievedResendPlayerValue() {
        match.sendPlayerValue(self.myValue)
    }
}

// MARK: Alerts
extension MultiPlayerViewController {
    
    func presentGameInit(completion: @escaping () -> Void) {
        tryDismissAlertAndPresent {
            let vc = UIAlertController(title: "The game is initializing", message: "please wait ...", preferredStyle: .actionSheet)
            self.present(vc, animated: true, completion: completion)
        }
    }
    
    func presentWaitingForCategoryFromOponent() {
        tryDismissAlertAndPresent {
            let vc = UIAlertController(title: "Opponent is choosing category", message: "please wait ...", preferredStyle: .actionSheet)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func presentChooseCategory() {
        tryDismissAlertAndPresent {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ChooseWordCategoryViewController.self))
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    func presentWaitingForOponentWord(completion: @escaping () -> Void) {
        tryDismissAlertAndPresent {
            let vc = UIAlertController(title: "Opponent is typing word", message: "please wait ...", preferredStyle: .actionSheet)
            self.present(vc, animated: true, completion: completion)
        }
    }
    
    func presentAlreadyUsed(word: String) {
        tryDismissAlertAndPresent {
            let alertVC = UIAlertController(title: "The word \"\(word)\" has been used", message: nil, preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentCharacterAreNotEqual(leftchar: String, rightChar: String) {
        tryDismissAlertAndPresent {
            let alertVC = UIAlertController(title: "Oooops, this word have to start with\n\n\(leftchar)", message: nil, preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentWordDoesNotExists(_ word: String) {
        tryDismissAlertAndPresent {
            let alertVC = UIAlertController(title: "\"\(word)\" is not in my dictionary", message: "Try another", preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentLoose() {
        gameState = .gameOver
        tryDismissAlertAndPresent {
            self.bonus.clearBonus()
            let alertVC = UIAlertController(title: "🐢 Ooops, you lose this game 🐢", message: nil, preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentWin(yourPoints: Int, oponentPoints: Int) {
        gameState = .gameOver
        tryDismissAlertAndPresent {
            self.bonus.clearBonus()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: GameSumaryViewController.self)) as! GameSumaryViewController
            vc.earnedPoints = yourPoints
            vc.presentingVC = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func presentGameOver(yourPoints: Int, oponentPoints: Int) {
        gameState = .gameOver
        tryDismissAlertAndPresent {
            self.bonus.clearBonus()
            let alertVC = UIAlertController(title: "Opponent left the game", message: "congratulation, you win all points", preferredStyle: .actionSheet)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: GameSumaryViewController.self)) as! GameSumaryViewController
                vc.earnedPoints = yourPoints
                vc.presentingVC = self
                self.present(vc, animated: true, completion: nil)
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

extension MultiPlayerViewController {
    
    fileprivate func setRandomWordFromSelectedCategory() {
        oponentWord = wordRepo.findRandomOne(for: selectedCategory!).value(forKey: "name") as? String
    }
}

extension MultiPlayerViewController: PresentingViewController {
    
    func dismissPresentedVC() {
        dismiss(animated: false, completion: {
            self.presentingVC?.dismissPresentedVC()
        })
    }
}
