// 
//  ProEndpoints.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 19.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum ProEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/pro/%@"
    
    case balances
    case addresses
    case withdraw
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
