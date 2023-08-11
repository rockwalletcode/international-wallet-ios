// 
//  VeriffSessionWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 13/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum BiometricType: String {
    case buy
    case pendingLimits = "pending_limits"
}

struct VeriffSessionRequestData: RequestModelData {
    var quoteId: String?
    var isBiometric: Bool?
    var biometricType: BiometricType?
    
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct VeriffSessionResponseData: ModelResponse {
    var url: String?
}

struct VeriffSession: Model {
    var sessionUrl: String
}

class VeriffSessionWorkerMapper: ModelMapper<VeriffSessionResponseData, VeriffSession> {
    override func getModel(from response: VeriffSessionResponseData?) -> VeriffSession? {
        return .init(sessionUrl: response?.url ?? "")
    }
}

class VeriffSessionWorker: BaseApiWorker<VeriffSessionWorkerMapper> {
    override func getUrl() -> String {
        guard let requestData = requestData as? VeriffSessionRequestData,
              let isBiometric = requestData.isBiometric,
              let biometricType = requestData.biometricType?.rawValue else {
            return KYCAuthEndpoints.veriffSession.url
        }
        
        var params: [String] = [isBiometric.description, biometricType]
        
        // Bio auth for limits doesn't require quoteId, so if no quoteId is present this call is being executed to confirm new limits
        guard let quoteId = requestData.quoteId else {
            return APIURLHandler.getUrl(KYCAuthEndpoints.veriffBiometricVerificationSessionLimits, parameters: params)
        }
        
        params.insert(quoteId, at: 0)
        
        return APIURLHandler.getUrl(KYCAuthEndpoints.veriffBiometricVerificationSession, parameters: params)
    }
}
