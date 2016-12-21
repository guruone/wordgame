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
    
    func extRemoveWithAnimation(layer: CALayer) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.removeFromSuperlayer()
        }
        let maskAnimation = CABasicAnimation(keyPath: "opacity")
        maskAnimation.fillMode = kCAFillModeForwards
        maskAnimation.toValue = 0
        maskAnimation.duration = 0.5
        maskAnimation.isRemovedOnCompletion = false
        layer.add(maskAnimation, forKey: "opacity")
    }
    
    func extSetLetterBlueBackground() {
        let image = UIImage(named: "background")!
        let color = UIColor(patternImage: image)
        backgroundColor = color
    }

    func extAddCenterRound() {
        let round = CALayer()
        round.frame = CGRect(x: 0,
                             y: center.y - frame.width / 2,
                             width: frame.width,
                             height: frame.width)
        round.backgroundColor = UIColor(red: 124/255, green: 209/255, blue: 117/255, alpha: 1).cgColor
        round.zPosition = -1
        round.cornerRadius = frame.width / 2
        layer.addSublayer(round)
    }
    
    enum ExtBorderOrientation {
        case left(width: CGFloat), right(width: CGFloat), top(width: CGFloat), bottom(width: CGFloat), all(width: CGFloat)
    }
    
    //TODO: orientation to Set<ExtBorderOrientation>
    func extAddBorder(_ orientation: [ExtBorderOrientation]) {
        let borderColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        
        for borderOrientation in orientation {
            
            if case .all(let width) = borderOrientation {
                layer.borderColor = borderColor
                layer.borderWidth = width
                
            } else {
                let border = CALayer()
                
                switch borderOrientation {
                case .left(let width):
                    border.frame = CGRect(x: 0,
                                          y: 0,
                                          width: width,
                                          height: frame.height)
                    break
                    
                case .right(let width):
                    border.frame = CGRect(x: frame.width,
                                          y: 0,
                                          width: width,
                                          height: frame.height)
                    break
                    
                case .top(let width):
                    border.frame = CGRect(x: 0,
                                          y: 0,
                                          width: frame.width,
                                          height: width)
                    break
                    
                case .bottom(let width):
                    border.frame = CGRect(x: 0,
                                          y: frame.height,
                                          width: frame.width,
                                          height: width)
                    
                    break
                case .all(_):
                    break
                }
                
                border.backgroundColor = borderColor
                layer.addSublayer(border)
            }
        }
    }
    
    func extAddVerticalLinesFromTop(to destinationView: UIView, offsetFromEdges offset: CGFloat, renderToView toView: UIView? = nil) {
        let leftLine = CALayer()
        leftLine.zPosition = -1
        leftLine.frame = CGRect(x: destinationView.frame.origin.x + offset,
                                y: self.frame.origin.y,
                                width: 2,
                                height: destinationView.frame.origin.y - self.frame.origin.y + destinationView.frame.height)
        leftLine.backgroundColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        
        let rightLine = CALayer()
        rightLine.zPosition = -1
        rightLine.frame = CGRect(x: destinationView.frame.origin.x + destinationView.frame.width - offset - 2,
                                 y: self.frame.origin.y,
                                 width: 2,
                                 height: destinationView.frame.origin.y - self.frame.origin.y + destinationView.frame.height)
        rightLine.backgroundColor = UIColor(red: 252/255, green: 233/255, blue: 212/255, alpha: 1).cgColor
        
        if toView == nil {
            self.layer.addSublayer(leftLine)
            self.layer.addSublayer(rightLine)
            
        } else {
            toView?.layer.addSublayer(leftLine)
            toView?.layer.addSublayer(rightLine)
        }
    }
}
