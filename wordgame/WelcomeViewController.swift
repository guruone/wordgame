//
//  WelcomeViewController.swift
//  wordgame
//
//  Created by Marek Mako on 23/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import GameKit

class WelcomeViewController: BaseViewController {
    
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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewBehingImageView: UIView!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(viewMask)
        view.extSetLetterBlueBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isViewDecorated {
            isViewDecorated = true
            
            view.extAddCenterRound()
            viewBehingImageView.extAddBorder([.all(width: 5)])
            startButton.extAddBorder([.all(width: 5)])
            decorateWithVerticalLines()
            
            view.extRemoveWithAnimation(layer: viewMask)
        }
    }
}

// MARK: GRAFIKA
fileprivate extension WelcomeViewController {
    
    func decorateWithVerticalLines() {
        // FROM TOP to stackView
        addLinesFromTopToStackView()
        
        // FROM viewBehingImageView to startButton
        addLinesFromViewBehindImageViewToStartButton()
    }
    
    private func addLinesFromTopToStackView() {
        let xFromLeft = stackView.frame.origin.x + 30
        let yFromLeft: CGFloat = 0
    
        let xToLeft = xFromLeft
        let yToLeft = stackView.frame.origin.y
        
        let xFromRight = stackView.bounds.width + stackView.frame.origin.x - 30
        let yFromRight: CGFloat = 0
        
        let xToRight = xFromRight
        let yToRight = stackView.frame.origin.y
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xFromLeft, y: yFromLeft))
        path.addLine(to: CGPoint(x: xToLeft, y: yToLeft))
        
        path.move(to: CGPoint(x: xFromRight, y: yFromRight))
        path.addLine(to: CGPoint(x: xToRight, y: yToRight))
        
        // RENDER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        
        view.layer.addSublayer(shapeLayer)
    }
    
    private func addLinesFromViewBehindImageViewToStartButton() {
        let xFromLeft: CGFloat = 0
        let xToLeft = startButton.frame.origin.x
        
        let yFromLeft = viewBehingImageView.bounds.height
        let yToLeft = startButton.frame.origin.y
        
        let xFromRight = viewBehingImageView.bounds.width
        let xToRight = startButton.frame.origin.x + startButton.bounds.width
        
        let yFromRight = viewBehingImageView.bounds.height
        let yToRight = startButton.frame.origin.y
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: xFromLeft + 5, y: yFromLeft - 1))
        path.addLine(to: CGPoint(x: xToLeft + 1, y: yToLeft + 1))
        
        path.move(to: CGPoint(x: xFromRight - 5, y: yFromRight - 1))
        path.addLine(to: CGPoint(x: xToRight - 1, y: yToRight + 1))
        
        // RENDER
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        
        stackView.layer.addSublayer(shapeLayer)
    }
}
