// 
//  AccountBlockedViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let AccountBlocked = AccountBlockedViewController.self
}

class AccountBlockedViewController: BaseInfoViewController {
    override var imageName: String? { return Asset.unlockWalletDisabled.name }
    override var titleText: String? { return L10n.Account.BlockedAccount.title }
    override var descriptionText: String? { return L10n.Account.BlockedAccount.description }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: L10n.ComingSoon.Buttons.backHome, callback: { [weak self] in
                self?.didTapMainButton?()
            }),
            .init(title: L10n.UpdatePin.contactSupport, isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapSecondaryButton?()
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
