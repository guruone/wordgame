//
//  UIView+.swift
//  wordgame
//
//  Created by Marek Mako on 11/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

// MARK: GRAFIKA
extension UIView {

    func extAddCenterRound() {
        let round = CALayer()
        round.frame = CGRect(x: 0,
                             y: center.y - frame.width / 2,
                             width: frame.width,
                             height: frame.width)
        round.backgroundColor = UIColor(red: 167/255, green: 224/255, blue: 165/255, alpha: 1).cgColor
        round.zPosition = -1
        round.cornerRadius = frame.width / 2
        layer.addSublayer(round)
    }
    
    func extAddBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0,
                                    y: frame.height,
                                    width: frame.width,
                                    height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        
        layer.addSublayer(bottomBorder)
    }
    
    func extAddBorder() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 5
    }
    
    func extAddVerticalLinesFromTop(to destinationView: UIView, offsetFromEdges offset: CGFloat) {
        let leftLine = CALayer()
        leftLine.frame = CGRect(x: destinationView.frame.origin.x + offset,
                                y: 0,
                                width: 2,
                                height: destinationView.frame.origin.y)
        leftLine.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(leftLine)
        
        let rightLine = CALayer()
        rightLine.frame = CGRect(x: destinationView.frame.origin.x + destinationView.frame.width - offset,
                                 y: 0,
                                 width: 2,
                                 height: destinationView.frame.origin.y)
        rightLine.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(rightLine)
    }
    
    func extAddLeftTopRighBorder() {
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 5,
                                  height: frame.height)
        leftBorder.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(leftBorder)
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0,
                                 y: 0,
                                 width: frame.width,
                                 height: 5)
        topBorder.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(topBorder)
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: frame.width,
                                   y: 0,
                                   width: 5,
                                   height: frame.height)
        rightBorder.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(rightBorder)
    }
}
