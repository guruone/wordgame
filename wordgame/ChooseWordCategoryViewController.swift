//
//  ChooseWordCategoryViewController.swift
//  wordgame
//
//  Created by Marek Mako on 12/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

class ChooseWordCategoryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var okButton: UIButton!
    
    @IBAction func onOKClick() {
        guard let gameVC = self.presentingViewController! as? GameViewController else {
            fatalError("parent viewController musi implementovat GameViewController")
        }
        dismiss(animated: true, completion: {
            let selectedCategoryIndex = self.categoryPickerView.selectedRow(inComponent: 0)
            gameVC.setSelectedWordCategory(WordCategory.allValues[selectedCategoryIndex])
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.extSetLetterBlueBackground()
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.extAddCenterRound()
        categoryPickerView.extAddBorder()
        okButton.extAddBorder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return WordCategory.allValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return WordCategory.allValues[row].rawValue
    }
}
