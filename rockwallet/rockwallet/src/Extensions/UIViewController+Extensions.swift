//
//  UIViewController+Extensions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

enum NavBarButtonSide {
    case left
    case right
}

enum NavBarButtonPosition {
    case left, middle, right
}

extension UIViewController {
    func addChildViewController(_ viewController: UIViewController, layout: () -> Void) {
        addChild(viewController)
        view.addSubview(viewController.view)
        layout()
        viewController.didMove(toParent: self)
    }
    
    func addCloseNavigationItem(side: NavBarButtonSide = .left, didDismiss: (() -> Void)? = nil) {
        let close = side == .left ? UIButton.buildModernCloseButton(position: .left) : UIButton.buildModernCloseButton(position: .right)
        close.tintColor = navigationController?.navigationItem.titleView?.tintColor
        close.tap = { [weak self] in
            self?.dismiss(animated: true, completion: {
                didDismiss?()
            })
        }
        
        switch side {
        case .left:
            navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: close)]
            
        case .right:
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: close)]
            
        }
    }
    
    func setAsNonDismissableModal() {
        isModalInPresentation = true
    }
}
