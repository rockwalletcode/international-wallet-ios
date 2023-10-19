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
    let ipAddress: String
    let location: String
    let device: String
}

struct AuthorizationStartedResponseModel: ModelResponse {
    let timeoutSeconds: Int
    let ip: String?
    let location: String?
    let device: String?
}

class AuthorizationStartedMapper: ModelMapper<AuthorizationStartedResponseModel, AuthorizationStartedModel> {
    override func getModel(from response: AuthorizationStartedResponseModel?) -> AuthorizationStartedModel? {
        guard let response else { return nil }
        return AuthorizationStartedModel(countdownTime: TimeInterval(exactly: response.timeoutSeconds) ?? Constant.authorizeLoginTime,
                                         ipAddress: response.ip ?? "/",
                                         location: response.location ?? "/",
                                         device: response.device ?? "/")
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
