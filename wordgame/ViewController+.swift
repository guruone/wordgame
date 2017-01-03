//
//  ViewController+.swift
//  wordgame
//
//  Created by Marek Mako on 30/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit

extension UIViewController {

    func tryDismissAlertAndPresent(completion: @escaping () -> Void) {
        if presentedViewController is UIAlertController {
            dismiss(animated: true, completion: completion)
            
        } else {
            completion()
        }
    }
}
