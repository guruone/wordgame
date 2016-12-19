//
//  ChooseWordCategoryViewController.swift
//  wordgame
//
//  Created by Marek Mako on 12/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

class ChooseWordCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryStackView: UIStackView!
    
    @IBAction func onNounsClick() {
        onClick(WordCategory.nouns)
    }
    
    @IBAction func onNamesClick() {
        onClick(WordCategory.names)
    }
    
    private func onClick(_ category: WordCategory) {
        guard let gameVC = self.presentingViewController! as? GameViewController else {
            fatalError("parent viewController musi implementovat GameViewController")
        }
        dismiss(animated: true, completion: {
            gameVC.setSelectedWordCategory(category)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.extSetLetterBlueBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.extAddCenterRound()
        view.extAddVerticalLinesFromTop(to: categoryStackView, offsetFromEdges: 50)
    }
}
