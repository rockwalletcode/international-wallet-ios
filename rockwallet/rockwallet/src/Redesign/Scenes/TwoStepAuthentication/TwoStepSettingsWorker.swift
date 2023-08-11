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
    var method: HTTPMethod
    var sending: Bool?
    var achSell: Bool?
    var buy: Bool?
    
    func getParameters() -> [String: Any] {
        let params = [
            "sending": sending,
            "achSell": achSell,
            "buy": buy
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct TwoStepSettingsResponseData: ModelResponse {
    enum TwoStepType: String, ModelResponse, CaseIterableDefaultsLast {
        case email = "EMAIL"
        case authenticator = "AUTHENTICATOR"
        
        case unknown
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
    
    override func getMethod() -> HTTPMethod {
        let method = (requestData as? TwoStepSettingsRequestData)?.method ?? .get
        return method
    }
}
