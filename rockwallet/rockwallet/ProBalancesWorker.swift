// 
//  ProBalancesWorker.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 19.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ProBalancesRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct ProBalancesResponseData: ModelResponse {
}

struct ProBalancesModel: Model {
}

class ProBalancesMapper: ModelMapper<ProBalancesResponseData, ProBalancesModel> {
    override func getModel(from response: ProBalancesResponseData?) -> ProBalancesModel? {
        return .init()
    }
}

class ProBalancesWorker: BaseApiWorker<ProBalancesMapper> {
    override func getUrl() -> String {
        return ProEndpoints.balances.url
    }
}
