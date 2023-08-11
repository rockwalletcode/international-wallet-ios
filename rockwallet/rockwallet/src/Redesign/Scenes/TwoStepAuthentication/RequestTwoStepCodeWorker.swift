// 
//  RequestTwoStepCodeWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 19/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct RequestTwoStepCodeRequestData: RequestModelData {
    var email: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "email": email ?? UserDefaults.email
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct RequestTwoStepCodeResponseData: ModelResponse {
}

struct RequestTwoStepCode: Model {
}

class RequestTwoStepCodeMapper: ModelMapper<RequestTwoStepCodeResponseData, RequestTwoStepCode> {
    override func getModel(from response: RequestTwoStepCodeResponseData?) -> RequestTwoStepCode? {
        return .init()
    }
}

class RequestTwoStepCodeWorker: BaseApiWorker<RequestTwoStepCodeMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.emailRequest.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
