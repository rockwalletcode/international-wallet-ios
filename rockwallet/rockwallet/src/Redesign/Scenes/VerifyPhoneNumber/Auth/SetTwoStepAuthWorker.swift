// 
//  SetTwoStepAuthWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepAuthRequestData: RequestModelData {
    enum AuthType {
        case app, email
    }
    var type: AuthType
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct SetTwoStepAuthResponseData: ModelResponse {
    let code: String?
    let url: String?
}

struct SetTwoStepAuth: Model {
    let code: String
    let url: String
}

class SetTwoStepAuthMapper: ModelMapper<SetTwoStepAuthResponseData, SetTwoStepAuth> {
    override func getModel(from response: SetTwoStepAuthResponseData?) -> SetTwoStepAuth? {
        return .init(code: response?.code ?? "", url: response?.url ?? "")
    }
}

class SetTwoStepAuthWorker: BaseApiWorker<SetTwoStepAuthMapper> {
    override func getUrl() -> String {
        guard let type = (requestData as? SetTwoStepAuthRequestData)?.type else { return "" }
        
        switch type {
        case .app:
            return TwoStepEndpoints.totp.url
            
        case .email:
            return TwoStepEndpoints.email.url
            
        }
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
