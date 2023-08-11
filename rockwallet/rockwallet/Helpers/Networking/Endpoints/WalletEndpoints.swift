// 
//  WalletAPI.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 16/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum WalletEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/wallet/auth/%@"
    
    case profile = "v3/profile"
    case profileSecondFactorCode = "v3/profile?second_factor_code=%@"
    case profileSecondFactorBackup = "v3/profile?second_factor_backup=%@"
    case profileMain = "profile"
    
    case register
    case login
    case resend = "resend-email"
    case confirm = "confirm_email"
    case reset = "password/reset"
    case set = "password/set"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
