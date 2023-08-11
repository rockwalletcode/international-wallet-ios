// 
//  TwoStepExchangeWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepExchangeRequestData: RequestModelData {
    let code: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "code": code
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct TwoStepExchangeResponseData: ModelResponse {
    let updateCode: String?
}

struct TwoStepExchange: Model {
    let updateCode: String?
    
}

class TwoStepExchangeMapper: ModelMapper<TwoStepExchangeResponseData, TwoStepExchange> {
    override func getModel(from response: TwoStepExchangeResponseData?) -> TwoStepExchange? {
        return .init(updateCode: response?.updateCode)
    }
}

class TwoStepExchangeWorker: BaseApiWorker<TwoStepExchangeMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.exchange.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
