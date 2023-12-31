// 
//  BorderConfiguration.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BorderConfiguration: BorderConfigurable {
    var tintColor: UIColor = .clear
    var borderWidth: CGFloat
    var cornerRadius: CornerRadius
    var maskedCorners: CACornerMask?
}
