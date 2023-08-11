// 
//  TwoStepEndpoints.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 24/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum TwoStepEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/wallet/2fa/%@"
    
    case settings
    case change
    case exchange
    case phone
    case phoneConfirm = "phone/confirm"
    case email
    case emailRequest = "email/request"
    case totp
    case totpConfirm = "totp/confirm"
    case recovery = "totp/recovery"
    case delete = ""
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
