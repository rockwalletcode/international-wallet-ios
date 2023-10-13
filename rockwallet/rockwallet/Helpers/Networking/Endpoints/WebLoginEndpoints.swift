// 
//  WebEndpoints.swift
//  rockwallet
//
//  Created by Dino Gačević on 12/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum WebLoginEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/web/%@"
    
    case progress = "auth/%@/progress"
    case login = "auth/login"
    case reject = "auth/reject"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
