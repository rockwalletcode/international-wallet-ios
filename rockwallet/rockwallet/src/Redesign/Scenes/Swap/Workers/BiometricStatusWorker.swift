// 
//  BiometricStatusWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 02/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum BiometricStatusCases: String, Codable {
    case notStarted = "not_started"
    case expired
    case started
    case submitted
    case approved
    case declined
    case abandoned
}

struct BiometricStatusRequestData: RequestModelData {
    var quoteId: String?
    
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct BiometricStatusResponseData: ModelResponse {
    var status: String?
}

struct BiometricStatus: Model {
    var status: BiometricStatusCases = .notStarted
}

class BiometricStatusMapper: ModelMapper<BiometricStatusResponseData, BiometricStatus> {
    override func getModel(from response: BiometricStatusResponseData?) -> BiometricStatus? {
        return .init(status: BiometricStatusCases(rawValue: response?.status ?? "") ?? .notStarted)
    }
}

class BiometricStatusWorker: BaseApiWorker<BiometricStatusMapper> {
    override func getUrl() -> String {
        
        guard let quoteId = (requestData as? BiometricStatusRequestData)?.quoteId else {
            return APIURLHandler.getUrl(KYCAuthEndpoints.longPollBiometricStatusLimits, parameters: [BiometricType.pendingLimits.rawValue])
        }
        
        return APIURLHandler.getUrl(KYCAuthEndpoints.longPollBiometricStatus, parameters: [quoteId])
    }
}
