// 
//  AuthorizeLoginWorker.swift
//  rockwallet
//
//  Created by Dino Gačević on 10/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct AuthorizeLoginResponse: ModelResponse {
    
}

struct AuthorizeLogin: Model {
    
}

class AuthorizeLoginMapper: ModelMapper<AuthorizeLoginResponse, AuthorizeLogin> {
    override func getModel(from response: AuthorizeLoginResponse?) -> AuthorizeLogin? {
        return .init()
    }
}

class AuthorizeLoginWorker: BaseApiWorker<AuthorizeLoginMapper> {
    override func getUrl() -> String {
        return ""
    }
}
