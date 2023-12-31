// 
//  Oauth2LoginWorker.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 22.8.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct Oauth2LoginRequestData: RequestModelData {
    let parameters: [String: String]?
    let sortedParameters: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "parameters": parameters
        ]
        return params.compactMapValues { $0 }
    }  
}

struct Oauth2LoginResponseData: ModelResponse {
    let redirectUri: String?
}

struct Oauth2Login: Model {
    let redirectUri: String
}

class Oauth2LoginMapper: ModelMapper<Oauth2LoginResponseData, Oauth2Login> {
    override func getModel(from response: Oauth2LoginResponseData?) -> Oauth2Login? {
        return .init(Oauth2Login(redirectUri: response?.redirectUri ?? ""))
    }
}

class Oauth2LoginWorker: BaseApiWorker<Oauth2LoginMapper> {
    override func getHeaders() -> [String: String] {
        let sortedParameters = (requestData as? Oauth2LoginRequestData)?.sortedParameters
        
        return UserSignature().getHeaders(nonce: sortedParameters, token: "")
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(Oauth2Endpoints.createToken)
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
