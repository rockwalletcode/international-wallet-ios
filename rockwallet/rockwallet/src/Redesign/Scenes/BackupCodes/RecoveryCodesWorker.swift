// 
//  GetRecoveryCodesWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct GetRecoveryCodesRequestData: RequestModelData {
    var method: HTTPMethod
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct GetRecoveryCodesResponseData: ModelResponse {
    let codes: [String]?
    let used: [String]?
}

struct GetRecoveryCodes: Model {
    let codes: [String]
    let used: [String]
}

class GetRecoveryCodesMapper: ModelMapper<GetRecoveryCodesResponseData, GetRecoveryCodes> {
    override func getModel(from response: GetRecoveryCodesResponseData?) -> GetRecoveryCodes? {
        return .init(codes: response?.codes ?? [], used: response?.used ?? [])
    }
}

class GetRecoveryCodesWorker: BaseApiWorker<GetRecoveryCodesMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.recovery.url
    }
    
    override func getMethod() -> HTTPMethod {
        let method = (requestData as? GetRecoveryCodesRequestData)?.method ?? .get
        return method
    }
}
