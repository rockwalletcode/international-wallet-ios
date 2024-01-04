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
        let params: [String: Any?] = [
            "addresses": addresses,
            "xpubs": xpubs
        ]
        
        return params.compactMapValues { $0 }
    }
}

class PostAddressesWorker: BaseApiWorker<PlainMapper> {
    override func getHeaders() -> [String: String] {
        let sortedAddresses = (requestData as? PostAddressesRequestData)?.sortedAddresses
        let sortedXpubs = (requestData as? PostAddressesRequestData)?.sortedXpubs
        
        return UserSignature().getHeadersAddresses(address: sortedAddresses, xpub: sortedXpubs)
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



struct GetAddressesRequestData: RequestModelData {
    let currencyCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "currencyCode": currencyCode
        ]
        return params.compactMapValues { $0 }
    }
}

class GetAddressesWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        guard let currencyCode = (requestData as? GetAddressesRequestData)?.currencyCode else { return "" }
        
        return APIURLHandler.getUrl(AddressesEndpoints.getAddresses, parameters: currencyCode)
    }
}
