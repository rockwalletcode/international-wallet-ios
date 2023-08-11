// 
//  TouchSpamPreventer.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 14/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

private var touchSpamPreventedViews = [WrapperTableViewCell<FETextField>.self,
                                       WrapperTableViewCell<NavigationItemView>.self]

extension UIView {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard touchSpamPreventedViews.contains(where: { self.isKind(of: $0) }) else { return }
        
        guard isUserInteractionEnabled else { return }
        isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.long.rawValue) { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
}
