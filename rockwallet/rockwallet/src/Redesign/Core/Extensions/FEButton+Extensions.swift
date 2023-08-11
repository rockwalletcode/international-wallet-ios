// 
//  FEButton+Extensions.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 23/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension FEButton {
    func toggleButtonStateWithTimer() {
        isEnabled = false
        var stateChangeTimer: Timer?
        stateChangeTimer = Timer.scheduledTimer(withTimeInterval: Presets.Delay.buttonState.rawValue, repeats: false) { [weak self] _ in
            self?.viewModel?.enabled = false
            self?.setup(with: self?.viewModel)
        }
        
        var countdownTimer: Timer?
        let title = viewModel?.title ?? ""
        var countdown = Int(Presets.Delay.buttonState.rawValue)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: Presets.Delay.regular.rawValue, repeats: true) { [weak self] _ in
            countdown -= 1
            
            self?.viewModel?.title = countdown == 0 ? title : title + " (\(countdown)s)"
            
            if countdown == 0 {
                countdownTimer?.invalidate()
                
                self?.viewModel?.enabled = true
            }
            
            self?.setup(with: self?.viewModel)
        }
        
        stateChangeTimer?.fire()
        countdownTimer?.fire()
    }
}
