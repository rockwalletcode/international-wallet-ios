// 
//  SardineSessionWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 28/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SardineSessionRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct SardineSessionResponseData: ModelResponse {
    var sardineSessionKey: String?
}

struct SardineSession: Model {
    var sessionKey: String?
}

class SardineSessionMapper: ModelMapper<SardineSessionResponseData, SardineSession> {
    override func getModel(from response: SardineSessionResponseData?) -> SardineSession? {
        return .init(sessionKey: response?.sardineSessionKey)
    }
}

class SardineSessionWorker: BaseApiWorker<SardineSessionMapper> {
    override func getUrl() -> String {
        return SardineEndpoints.session.url
    }
}
