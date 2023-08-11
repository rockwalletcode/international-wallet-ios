//
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

class VerifyAccountViewController: BaseInfoViewController {
    var flow: ProfileModels.ExchangeFlow?
    
    override var imageName: String? { return Asset.verification.name }
    override var titleText: String? { return L10n.Account.verifyAccountTitle }
    override var descriptionText: String? { return L10n.Account.verifyAccountDescription }
    override var isModalDismissableEnabled: Bool { return false }
    
    override var buttonViewModels: [ButtonViewModel] {
        switch flow {
        case .buy, .swap:
            return [
                .init(title: L10n.Button.back, callback: { [weak self] in
                    self?.shouldDismiss = true
                    
                    self?.didTapMainButton?()
                }),
                .init(title: L10n.ComingSoon.Buttons.contactSupport, isUnderlined: true, callback: { [weak self] in
                    self?.didTapSecondaryButton?()
                })
            ]
            
        case .sell:
            return [
                .init(title: L10n.Button.verify, callback: { [weak self] in
                    self?.shouldDismiss = true
                    
                    self?.didTapMainButton?()
                }),
                .init(title: L10n.Button.maybeLater, isUnderlined: true, callback: { [weak self] in
                    self?.shouldDismiss = true
                    
                    self?.didTapSecondaryButton?()
                })
            ]
            
        default:
            return []
        }
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
