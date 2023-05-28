// 
//  ExchangeHistoryWorker.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 25.7.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ExchangeDetailsExchangesResponseData: ModelResponse {
    var exchanges: [ExchangeDetailsResponseData]
}

class ExchangeHistoryMapper: ModelMapper<ExchangeDetailsExchangesResponseData, [ExchangeDetail]> {
    override func getModel(from response: ExchangeDetailsExchangesResponseData?) -> [ExchangeDetail] {
        var exchanges = (response?.exchanges ?? []).compactMap { ExchangeDetailsMapper().getModel(from: $0) }
        
        var hybridExchanges: [ExchangeDetail] = []
        
        for exchange in exchanges where exchange.instantDestination?.transactionId != nil {
            var one = exchange
            one.part = .one
            hybridExchanges.insert(one, at: 0)
            
            var two = exchange
            two.part = .two
            hybridExchanges.insert(two, at: 0)
            
            exchanges = exchanges.filter { $0 != exchange }
        }
        
        exchanges.append(contentsOf: hybridExchanges)
        
        return exchanges
    }
}

class ExchangeHistoryWorker: BaseApiWorker<ExchangeHistoryMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.history.url
    }
}
