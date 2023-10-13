// 
//  WebLoginWorker.swift
//  rockwallet
//
//  Created by Dino Gačević on 12/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct AuthorizeLoginRequestData: RequestModelData {
    let email: String?
    let token: String?
    let deviceToken: String?
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "email": email,
            "token": token,
            "device_token": deviceToken
        ]
        
        return params.compactMapValues { $0 }
    }
}

class AuthorizeLoginWorker: BaseApiWorker<PlainMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: requestData?.getParameters()["email"] as? String,
                                          token: requestData?.getParameters()["device_token"] as? String)
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(WebLoginEndpoints.login)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
