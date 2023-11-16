// 
//  ProSupportedCurrencies.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 28.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ProSupportedCurrenciesResponseData: ModelResponse {
    var supportedCurrencies: [SupportedCurrencies]?
    
    struct SupportedCurrencies: Codable {
        var currency: String?
        var blockchain: String?
        var address: String?
        var depositTag: String?
    }
}

struct ProSupportedCurrenciesModel: Model {
    var currency: String
    var blockchain: String
    var address: String
    var depositTag: String
}

class ProSupportedCurrenciesMapper: ModelMapper<ProSupportedCurrenciesResponseData, [ProSupportedCurrenciesModel]> {
    override func getModel(from response: ProSupportedCurrenciesResponseData?) -> [ProSupportedCurrenciesModel]? {
        guard let response = response else { return nil }
        
        let supportedCurrencies = response.supportedCurrencies?.compactMap({
            return ProSupportedCurrenciesModel(currency: $0.currency ?? "",
                                               blockchain: $0.blockchain ?? "",
                                               address: $0.address ?? "",
                                               depositTag: $0.depositTag ?? "") })
        return supportedCurrencies
    }
}

class ProSupportedCurrenciesWorker: BaseApiWorker<ProSupportedCurrenciesMapper> {
    override func getUrl() -> String {
        return ProEndpoints.addresses.url
    }
}
