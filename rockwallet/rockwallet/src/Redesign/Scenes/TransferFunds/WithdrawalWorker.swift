// 
//  WithdrawalWorker.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 25.10.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct WithdrawalRequestData: RequestModelData {
    let amount: String?
    let address: String?
    let asset: String?
    
    func getParameters() -> [String: Any] {
        let params = [ "amount": amount,
                       "address": address,
                       "asset": asset ]
        
        return params.compactMapValues { $0 }
    }
}

class WithdrawalWorker: BaseApiWorker<PlainMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeadersWithdraw(amount: (getParameters()["amount"] as? String),
                                                  address: (getParameters()["address"] as? String),
                                                  asset: (getParameters()["asset"] as? String))
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(ProEndpoints.withdraw)
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
