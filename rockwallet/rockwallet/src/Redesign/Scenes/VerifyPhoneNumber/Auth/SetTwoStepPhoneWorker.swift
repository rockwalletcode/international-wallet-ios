// 
//  SetTwoStepPhoneWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 31/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepPhoneRequestData: RequestModelData {
    var phone: String
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "phone": phone,
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct SetTwoStepPhoneResponseData: ModelResponse {
}

struct SetTwoStepPhone: Model {
}

class SetTwoStepPhoneMapper: ModelMapper<SetTwoStepPhoneResponseData, SetTwoStepPhone> {
    override func getModel(from response: SetTwoStepPhoneResponseData?) -> SetTwoStepPhone? {
        return .init()
    }
}

class SetTwoStepPhoneWorker: BaseApiWorker<SetTwoStepPhoneMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.phone.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
