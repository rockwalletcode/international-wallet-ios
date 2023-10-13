// 
//  AuthorizationStartedWorker.swift
//  rockwallet
//
//  Created by Dino Gačević on 10/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct AuthorizationStartedModel: Model {
    let countdownTime: TimeInterval
}

struct AuthorizationStartedResponseModel: ModelResponse {
    let timeoutSeconds: Int
}

class AuthorizationStartedMapper: ModelMapper<AuthorizationStartedResponseModel, AuthorizationStartedModel> {
    override func getModel(from response: AuthorizationStartedResponseModel?) -> AuthorizationStartedModel? {
        guard let time = response?.timeoutSeconds else { return nil }
        return .init(countdownTime: TimeInterval(exactly: time) ?? Constant.authorizeLoginTime)
    }
}

class AuthorizationStartedWorker: BaseApiWorker<AuthorizationStartedMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(WebLoginEndpoints.progress, parameters: DynamicLinksManager.shared.loginToken ?? "")
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
