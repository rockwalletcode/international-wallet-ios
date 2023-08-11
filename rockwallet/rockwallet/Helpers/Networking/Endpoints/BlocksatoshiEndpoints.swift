// 
//  BlocksatoshiEndpoints.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum BlocksatoshiEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/blocksatoshi/%@"
    
    case paymailDestination = "paymail-destination"
    case convertBchAddress = "convert-bch-address?address=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
