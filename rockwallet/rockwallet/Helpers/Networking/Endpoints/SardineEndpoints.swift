// 
//  SardineEndpoints.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 28/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum SardineEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/one/sardine/%@"
    
    case session
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
