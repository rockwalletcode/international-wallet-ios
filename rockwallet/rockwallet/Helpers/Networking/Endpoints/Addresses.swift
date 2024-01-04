// 
//  Addresses.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 4.1.24.
//  Copyright © 2024 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum AddressesEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/wallet/%@"
    
    case addresses
    case getAddresses = "addresses?currencyCode=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
