// 
//  RegistrationWorker.swift
//  breadwallet
//
//  Created by Rok on 01/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class RegistrationMapper: ModelMapper<RegistrationResponseData, RegistrationData> {
    override func getModel(from response: RegistrationResponseData?) -> RegistrationData? {
        guard let sessionKey = response?.sessionKey, let sessionKeyHash = response?.sessionKeyHash else {
            return nil
        }
        
        return .init(sessionKey: sessionKey, sessionKeyHash: sessionKeyHash)
    }
}

struct RegistrationResponseData: ModelResponse {
    struct SessionData: ModelResponse {
        let sessionKey, sessionKeyHash: String?
    }
    
    var data: SessionData?
    
    var sessionKey: String? {
        return data?.sessionKey
    }
    var sessionKeyHash: String? {
        return data?.sessionKeyHash
    }
}

struct RegistrationData: Model {
    var sessionKey: String?
    var sessionKeyHash: String?
}

struct RegistrationRequestData: RequestModelData {
    let email: String?
    let password: String?
    let token: String?
    let subscribe: Bool?
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    enum AccountHandling {
        case register, login
    }
    
    let accountHandling: AccountHandling
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "email": email,
            "password": password,
            "token": token,
            "subscribe": subscribe,
            "second_factor_code": secondFactorCode,
            "second_factor_backup": secondFactorBackup
        ]
        
        return params.compactMapValues { $0 }
    }
}

class RegistrationWorker: BaseApiWorker<RegistrationMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: (getParameters()["email"] as? String),
                                          token: (getParameters()["token"] as? String))
    }
    
    override func getUrl() -> String {
        let accountHandling = (requestData as? RegistrationRequestData)?.accountHandling
        
        switch accountHandling {
        case .login:
            return APIURLHandler.getUrl(WalletEndpoints.login)
            
        case .register:
            return APIURLHandler.getUrl(WalletEndpoints.register)
            
        default:
            return ""
        }
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
