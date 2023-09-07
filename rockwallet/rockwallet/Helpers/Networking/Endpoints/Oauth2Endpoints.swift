// 
//  Oauth2Endpoints.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 22.8.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum Oauth2Endpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/%@"
    
    case createToken = "oauth2/mobile/token"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
