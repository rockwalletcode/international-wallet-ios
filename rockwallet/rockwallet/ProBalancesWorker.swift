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
    var mnet: Decimal?
    var usdc: Decimal?
    var btc: Decimal?
    var eth: Decimal?
    var bsv: Decimal?
}

struct ProBalancesModel: Model {
    var mnet: Decimal
    var usdc: Decimal
    var btc: Decimal
    var eth: Decimal
    var bsv: Decimal
}

class ProBalancesMapper: ModelMapper<ProBalancesResponseData, ProBalancesModel> {
    override func getModel(from response: ProBalancesResponseData?) -> ProBalancesModel? {
        return ProBalancesModel(mnet: response?.mnet ?? 0,
                                usdc: response?.usdc ?? 0,
                                btc: response?.btc ?? 0,
                                eth: response?.eth ?? 0,
                                bsv: response?.bsv ?? 0)
    }
}

class ProBalancesWorker: BaseApiWorker<ProBalancesMapper> {
    override func getUrl() -> String {
        return ProEndpoints.balances.url
    }
}
