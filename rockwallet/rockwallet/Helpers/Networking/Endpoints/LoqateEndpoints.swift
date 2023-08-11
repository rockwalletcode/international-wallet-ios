// 
//  LoqateEndpoints.swift
//  breadwallet
//
//  Created by Dino Gacevic on 14/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum LoquateEndpoints: String, URLType {
    static var baseURL: String = "https://api.addressy.com/Capture/Interactive/%@"
    
    case base = "Find/v1.1/json3.ws?Key=%@&Text=%@"
    case retrieve = "Retrieve/v1.20/json3.ws?Key=%@&Id=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
