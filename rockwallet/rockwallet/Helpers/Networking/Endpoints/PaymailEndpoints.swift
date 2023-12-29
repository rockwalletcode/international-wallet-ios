// 
//  PaymailEndpoints.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 25.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum PaymailEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/wallet/paymail?%@"
    
    case paymail = "paymail=%@&xpub=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

enum AddressesEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/wallet/%@"
    
    case addresses
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
