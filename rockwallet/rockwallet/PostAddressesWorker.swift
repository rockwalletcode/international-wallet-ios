// 
//  PostAddressesWorker.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 29.12.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct PostAddressesRequestData: RequestModelData {
    let addresses: [String: Any]?
    let xpubs: [String: Any]?
    let sortedXpubs: String?
    let sortedAddresses: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "addresses": addresses as Any,
            "xpubs": xpubs as Any
        ] as [String: Any]
        
        return params.compactMapValues { $0 }
    }
}

class PostAddressesWorker: BaseApiWorker<PlainMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: (getParameters()["sortedAddresses"] as? String),
                                          token: (getParameters()["sortedXpubs"] as? String))
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(AddressesEndpoints.addresses)
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
