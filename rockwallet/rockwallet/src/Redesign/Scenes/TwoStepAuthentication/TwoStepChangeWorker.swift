// 
//  TwoStepChangeWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepChangeRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct TwoStepChangeResponseData: ModelResponse {
}

struct TwoStepChange: Model {
}

class TwoStepChangeMapper: ModelMapper<TwoStepChangeResponseData, TwoStepChange> {
    override func getModel(from response: TwoStepChangeResponseData?) -> TwoStepChange? {
        return .init()
    }
}

class TwoStepChangeWorker: BaseApiWorker<TwoStepChangeMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.change.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
