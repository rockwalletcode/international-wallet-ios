// 
//  ExchangeWorker.swift
//  breadwallet
//
//  Created by Rok on 20/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct ExchangeRequestData: RequestModelData {
    var deviceId: String?
    var quoteId: Int?
    var depositQuantity: String
    var withdrawalQuantity: String
    var destination: String?
    var sourceInstrumentId: String?
    var nologCvv: String?
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "device_id": deviceId,
            "quote_id": quoteId,
            "deposit_quantity": depositQuantity,
            "withdrawal_quantity": withdrawalQuantity,
            "destination": destination,
            "source_instrument_id": sourceInstrumentId,
            "nolog_cvv": nologCvv,
            "second_factor_code": secondFactorCode,
            "second_factor_backup": secondFactorBackup
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct ExchangeResponseData: ModelResponse {
    var exchangeId: Int?
    var currency: String?
    var amount: String?
    var address: String?
    var status: String?
    var paymentReference: String?
    var redirectUrl: String?
    var destinationTag: String?
}

struct Exchange: Model {
    var exchangeId: String?
    var currency: String?
    var amount: Decimal?
    var address: String?
    var status: AddCard.Status?
    var paymentReference: String?
    var redirectUrl: String?
    var destinationTag: String?
}

class ExchangeMapper: ModelMapper<ExchangeResponseData, Exchange> {
    override func getModel(from response: ExchangeResponseData?) -> Exchange? {
        guard let response = response,
              let amount = Decimal(string: response.amount ?? "")
        else {
            return .init(status: .init(rawValue: response?.status ?? ""),
                         paymentReference: response?.paymentReference,
                         redirectUrl: response?.redirectUrl,
                         destinationTag: response?.destinationTag)
        }
        
        return .init(exchangeId: "\(response.exchangeId ?? 0)",
                     currency: response.currency?.uppercased() ?? "",
                     amount: amount,
                     address: response.address)
    }
}

class ExchangeWorker: BaseApiWorker<ExchangeMapper> {
    override func getMethod() -> HTTPMethod {
        return .post
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(ExchangeEndpoints.create)
    }
}
