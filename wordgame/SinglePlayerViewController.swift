//
//  SinglePlayerViewController.swift
//  wordgame
//
//  Created by Marek Mako on 09/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SinglePlayerViewController: UIViewController, GameViewController {
    
    let MAX_TIME_FOR_WORD = 20
    
    fileprivate var isViewDecorated = false
    
    fileprivate lazy var viewMask: CALayer = {
        let color = UIColor(red: 70/255, green: 127/255, blue: 215/255, alpha: 1)        
        let mask = CALayer()
        mask.frame = self.view.bounds
        mask.backgroundColor = color.cgColor
        mask.zPosition = CGFloat.greatestFiniteMagnitude
        return mask
    }()
    
    fileprivate let videoAd = VideoInterstitialAd()
    
    
    fileprivate enum RewardType {
        case hint, allowUseForbiddenWord(String)
    }
    fileprivate let rewardAd = RewardAd()
    fileprivate var reward: RewardType?
    
    fileprivate let gkscore = Score()
    
    fileprivate let wordRepo = WordRepository()
    
    fileprivate let bonus = BonusPoints.shared
    
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
            scheduledTimer()
        }
    }
    
    fileprivate func scheduledTimer() {
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
        bonus.clearBonus()
        timer?.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHintClick() {
        let lastChar = "\(oponentWord!.characters.last!)"
        currentWordTextField.text = wordRepo.findRandomOne(for: selectedCategory!, startWith: lastChar).value(forKey: "name") as? String
    }
    
    var ad: GADInterstitial?
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBAction func onPauseClick() {
        timer?.invalidate()
        ad?.present(fromRootViewController: self)
    }
    
    func setSelectedWordCategory(_ category: WordCategory) {
        selectedCategory = category
        oponentWord = wordRepo.findRandomOne(for: selectedCategory!).value(forKey: "name") as? String
    }
    
    fileprivate func gameOver() {
        bonus.clearBonus()
        gkscore.report(score: score!)
        presentGameOver(yourPoints: score!)
    }
}

// MARK: LIFECYCLE
extension SinglePlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)
        
        rewardAd.delegate = self
        
        pauseButton.isEnabled = false
        videoAd.delegate = self
        
        currentWordTextField.autocorrectionType = .no
        currentWordTextField.delegate = self
        
        timeRemaining = MAX_TIME_FOR_WORD
        score = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewDecorated {
            isViewDecorated = true
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
            
            view.extRemoveWithAnimation(layer: viewMask)
        }

        if gameState == .waitingToWordCategory {
            gameState = .waitingToOponentWord
            presentChooseCategory()
        }
    }
}

// MARK: UITextFieldDelegate - VALIDATCIA ZADANEHO SLOVA
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

// MARK: InterstitialAdDelegate
extension SinglePlayerViewController: InterstitialAdDelegate {
    
    func addWillLeaveApplication() {
        
    }

    func adIsReady(_ ad: GADInterstitial) {
        self.ad = ad
        pauseButton.isEnabled = true
    }
    
    func adDidDismissScreen() {
        pauseButton.isEnabled = false
        scheduledTimer()
    }
}

// MARK: RewardAdDelegate
extension SinglePlayerViewController: RewardAdDelegate {
    
    func rewardAd(didRewardUser reward: GADAdReward) {
        switch self.reward! {
        case .hint:
            self.onHintClick()
            break

        case .allowUseForbiddenWord(let word):
            let index = self.forbiddenWords.index(of: word)
            self.forbiddenWords.remove(at: index!)
            self.oponentWord = word
            break
        }
    }
}

// MARK: ALERTS
extension SinglePlayerViewController {
    
    func presentChooseCategory() {
        let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: ChooseWordCategoryViewController.self))
        present(vc!, animated: true, completion: nil)
    }
    
    func presentAlreadyUsed(word: String) {
        let alertVC = UIAlertController(title: "Slovo \(word) uz bolo pouzite", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Try another word", style: .cancel, handler: nil))
        if rewardAd.ad.isReady {
            alertVC.addAction(UIAlertAction(title: "Watch short movie to accept word", style: .default, handler: { (action: UIAlertAction) in
                self.view.endEditing(true)
                self.reward = SinglePlayerViewController.RewardType.allowUseForbiddenWord(word)
                self.timer?.invalidate()
                self.timeRemaining = self.MAX_TIME_FOR_WORD
                self.rewardAd.ad.present(fromRootViewController: self)
            }))
        }
        present(alertVC, animated: true, completion: nil)
    }
    
    func presentCharacterAreNotEqual(leftchar: String, rightChar: String) {
        let alertVC = UIAlertController(title: "Chyba", message: "\(leftchar) != \(rightChar)", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func presentWordDoesNotExists(_ word: String) {
        let alertVC = UIAlertController(title: "\(word) som nenasiel.", message: "Skus ine", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Try another word", style: .cancel, handler: nil))
        if rewardAd.ad.isReady {
            alertVC.addAction(UIAlertAction(title: "Watch short movie to hint", style: .default, handler: { (action: UIAlertAction) in
                self.view.endEditing(true)
                self.reward = SinglePlayerViewController.RewardType.hint
                self.timer?.invalidate()
                self.timeRemaining = self.MAX_TIME_FOR_WORD
                self.rewardAd.ad.present(fromRootViewController: self)
            }))
        }
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func presentGameOver(yourPoints: Int) {
        func completion() {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: String(describing: GameSumaryViewController.self)) as! GameSumaryViewController
            vc.earnedPoints = yourPoints
            vc.category = selectedCategory
            present(vc, animated: true, completion: nil)
        }
        
        if presentedViewController != nil {
            presentedViewController?.dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
}
