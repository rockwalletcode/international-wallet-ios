// 
//  ComingSoonViewController.swift
//  breadwallet
//
//  Created by Rok on 15/11/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let ComingSoon = ComingSoonViewController.self
}

class ComingSoonViewController: BaseInfoViewController {
    var reason: BaseInfoModels.ComingSoonReason? {
        didSet {
            prepareData()
        }
    }
    
    override var imageName: String? { reason?.iconName }
    
    override var titleText: String? { reason?.title }
    
    override var descriptionText: String? { reason?.description }
    
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: reason?.firstButtonTitle, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapMainButton?()
            })
        ]
    }
    
    override var buttonConfigurations: [ButtonConfiguration] { [Presets.Button.primary] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.KycComingSoon(type: String(describing: reason)))
    }
}
