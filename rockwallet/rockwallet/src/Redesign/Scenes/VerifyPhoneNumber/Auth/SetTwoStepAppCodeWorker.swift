// 
//  SetTwoStepAppCodeWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepAppCodeRequestData: RequestModelData {
    var code: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "code": code
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct SetTwoStepAppCodeResponseData: ModelResponse {
}

struct SetTwoStepAppCode: Model {
}

class SetTwoStepAppCodeMapper: ModelMapper<SetTwoStepAppCodeResponseData, SetTwoStepAppCode> {
    override func getModel(from response: SetTwoStepAppCodeResponseData?) -> SetTwoStepAppCode? {
        return .init()
    }
}

class SetTwoStepAppCodeWorker: BaseApiWorker<SetTwoStepAppCodeMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.totpConfirm.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
