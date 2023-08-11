// 
//  WalletPicker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 15/06/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct WalletPicker {
    static let wallets = [Currencies.shared.bsv?.wallet,
                          Currencies.shared.btc?.wallet,
                          Currencies.shared.bch?.wallet,
                          Currencies.shared.ltc?.wallet].compactMap({ $0 })
    
    static func present(on viewController: UIViewController?, fromURI uri: String? = nil, completion: ((Wallet) -> Void)?) {
        let alert = UIAlertController(title: L10n.Settings.importTitle, message: nil, preferredStyle: .actionSheet)
        
        let wallets = uri == nil ? WalletPicker.wallets : QRCode.detectPossibleWallets(fromURI: uri ?? "")
        
        wallets.forEach { wallet in
            alert.addAction(UIAlertAction(title: wallet.currency.code, style: .default, handler: { _ in
                completion?(wallet)
            }))
        }
        
        alert.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: nil))
        
        viewController?.present(alert, animated: true)
    }
}
