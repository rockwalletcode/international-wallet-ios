// 
//  UnlinkWalletViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 8.2.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let UnlinkWallet = UnlinkWalletViewController.self
}

class UnlinkWalletViewController: BaseInfoViewController {
    var exitAction: ExitRecoveryKeyAction?
    var exitCallback: DidExitRecoveryKeyIntroWithAction?
    
    override var imageName: String? { return Asset.security.name }
    override var titleText: String? { return L10n.RecoveryKeyFlow.unlinkWallet }
    override var descriptionText: String? { return L10n.RecoveryKeyFlow.unlinkWalletSubtext }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: L10n.RecoveryKeyFlow.generateKeyButton, callback: { [weak self] in
                if let exit = self?.exitCallback {
                    exit(self?.exitAction ?? .generateKey)
                }
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary]
    }
}
