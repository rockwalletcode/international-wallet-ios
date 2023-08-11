// 
//  Shadow+Background+Extensions.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 23/10/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
extension CALayer {
    func setShadow(with config: ShadowConfiguration) {
        let radius = cornerRadius == 0 ? (config.shadowRadius == .fullRadius ? bounds.height / 2 : config.shadowRadius.rawValue) : cornerRadius
        shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        shadowRadius = radius
        shadowOpacity = config.opacity.rawValue
        shadowOffset = config.offset
        shadowColor = UIColor.black.cgColor
        masksToBounds = false
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
}

extension UIView {
    func setBackground(with config: BackgroundConfiguration) {
        layer.backgroundColor = config.backgroundColor.cgColor
        
        guard let border = config.border else { return }
        
        let radius = border.cornerRadius == .fullRadius ? bounds.height / 2 : border.cornerRadius.rawValue
        
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.borderWidth = border.borderWidth
        layer.borderColor = border.tintColor.cgColor
        
        if let maskedCorners = border.maskedCorners {
            layer.maskedCorners = maskedCorners
        }
    }
}
