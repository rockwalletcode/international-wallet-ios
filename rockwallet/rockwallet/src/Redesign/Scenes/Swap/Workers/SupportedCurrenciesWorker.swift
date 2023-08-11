// 
//  SupportedCurrenciesWorker.swift
//  breadwallet
//
//  Created by Rok on 04/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SupportedCurrenciesResponseData: ModelResponse {
    var supportedCurrencies: [String]?
    var achSupportedCurrencies: [String]?
}

struct SupportedCurrency: Model {
    var supportedCurrencies: [String]
    var achSupportedCurrencies: [String]
}

class SupportedCurrenciesWorkerMapper: ModelMapper<SupportedCurrenciesResponseData, SupportedCurrency> {
    override func getModel(from response: SupportedCurrenciesResponseData?) -> SupportedCurrency {
        return .init(supportedCurrencies: response?.supportedCurrencies ?? [],
                     achSupportedCurrencies: response?.achSupportedCurrencies ?? [])
    }
}

class SupportedCurrenciesWorker: BaseApiWorker<SupportedCurrenciesWorkerMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.supportedCurrencies.url
    }
}
