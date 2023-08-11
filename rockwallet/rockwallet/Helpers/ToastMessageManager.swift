// 
//  ToastMessageManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ToastMessageManager {
    static let shared = ToastMessageManager()
    
    private var notifications: [FEInfoView] = []
    private var timer: Timer?
    
    func show(model: InfoViewModel? = nil,
              configuration: InfoViewConfiguration? = nil) {
        guard let activeWindow = UIApplication.shared.activeWindow else { return }
        
        let notification = FEInfoView()
        notification.setupCustomMargins(all: .extraLarge)
        notification.configure(with: configuration)
        notification.setup(with: model)
        activeWindow.addSubview(notification)
        notification.alpha = 0
        
        notification.didFinish = { [weak self] in
            self?.hide()
        }
        
        notification.snp.makeConstraints { make in
            make.top.equalTo(activeWindow.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(Margins.medium.rawValue)
            make.centerX.equalToSuperview()
        }
        
        notification.layoutIfNeeded()
        
        notifications.last?.removeFromSuperview()
        notifications.append(notification)
        
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: FEInfoViewDismissType.auto.rawValue,
                                     target: self,
                                     selector: #selector(hide),
                                     userInfo: nil,
                                     repeats: false)
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) {[weak self] in
            self?.notifications.last?.alpha = 1
        }
    }
    
    @objc func hide() {
        UIView.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.notifications.last?.alpha = 0
        }
    }
}
