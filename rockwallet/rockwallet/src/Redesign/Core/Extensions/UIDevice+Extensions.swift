// 
//  UIDevice+Extensions.swift
//  breadwallet
//
//  Created by Dino Gacevic on 21/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        return UIDevice.current.bottomNotch > 0
    }
    
    var bottomNotch: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return 0 }
        
        return window.safeAreaInsets.bottom
    }
    
    var topNotch: CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return 0 }
        
        return window.safeAreaInsets.top
    }
}
