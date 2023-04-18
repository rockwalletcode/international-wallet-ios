// 
//  TwoStepSettingsWorkers.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 24/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepSettingsRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct TwoStepSettingsResponseData: ModelResponse {
    enum TwoStepType: String, ModelResponse {
        case email = "EMAIL"
        case authenticator = "AUTHENTICATOR"
    }
    
    let type: TwoStepSettingsResponseData.TwoStepType?
    let sending: Bool?
    let achSell: Bool?
    let buy: Bool?
}

struct TwoStepSettings: Model {
    let type: TwoStepSettingsResponseData.TwoStepType?
    let sending: Bool
    let achSell: Bool
    let buy: Bool
}

class TwoStepSettingsMapper: ModelMapper<TwoStepSettingsResponseData, TwoStepSettings> {
    override func getModel(from response: TwoStepSettingsResponseData?) -> TwoStepSettings? {
        return .init(type: response?.type,
                     sending: response?.sending ?? false,
                     achSell: response?.achSell ?? false,
                     buy: response?.buy ?? false)
    }
}

class TwoStepSettingsWorker: BaseApiWorker<TwoStepSettingsMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.settings.url
    }
}
