//
//  StartNavigationDelegate.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-27.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import SwiftUI

class StartNavigationDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if viewController is RecoverWalletIntroViewController {
            navigationController.navigationBar.tintColor = .white
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: Fonts.Title.six
            ]
        }
        
        if viewController is EnterPhraseViewController {
            navigationController.navigationBar.tintColor = Colors.Text.one
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: Colors.primary,
                NSAttributedString.Key.font: Fonts.Title.six
            ]
        }
        
        if viewController is UpdatePinViewController {
            navigationController.navigationBar.tintColor = Colors.Text.one
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: Fonts.Title.six
            ]
            
            //Stop being able to swipe back from updating pin view
            if let gr = navigationController.interactivePopGestureRecognizer {
                navigationController.view.removeGestureRecognizer(gr)
            }
        }
        
        if viewController is UIHostingController<SelectBackupView> {
            navigationController.navigationBar.tintColor = Colors.Text.one
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: Colors.primary,
                NSAttributedString.Key.font: Fonts.Title.six
            ]
        }
    }
}
