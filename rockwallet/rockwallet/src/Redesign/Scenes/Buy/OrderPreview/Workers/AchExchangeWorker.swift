// 
//  AchExchangeWorker.swift
//  breadwallet
//
//  Created by Rok on 18/11/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct AchExchangeRequestData: RequestModelData {
    var deviceId: String?
    var quoteId: Int?
    var depositQuantity: String
    var withdrawalQuantity: String
    var destination: String?
    var accountId: String?
    var nologCvv: String?
    var useInstantAch: Bool?
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "device_id": deviceId,
            "quote_id": quoteId,
            "deposit_quantity": depositQuantity,
            "withdrawal_quantity": withdrawalQuantity,
            "destination": destination,
            "account_id": accountId,
            "nolog_cvv": nologCvv,
            "use_instant_ach": useInstantAch,
            "second_factor_code": secondFactorCode,
            "second_factor_backup": secondFactorBackup
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct AchExchangeResponseData: ModelResponse {
    var exchangeId: Int?
    var currency: String?
    var amount: String?
    var address: String?
    var status: String?
    var paymentReference: String?
    var redirectUrl: String?
}

struct AchExchange: Model {
    var exchangeId: String?
    var currency: String?
    var amount: Decimal?
    var address: String?
    var status: AddCard.Status?
    var paymentReference: String?
    var redirectUrl: String?
}

class AchExchangeWorkerMapper: ModelMapper<AchExchangeResponseData, Exchange> {
    override func getModel(from response: AchExchangeResponseData?) -> Exchange? {
        guard let response = response,
              let amount = Decimal(string: response.amount ?? "")
        else {
            return .init(status: .init(rawValue: response?.status ?? ""),
                         paymentReference: response?.paymentReference,
                         redirectUrl: response?.redirectUrl)
        }
        
        return .init(exchangeId: "\(response.exchangeId ?? 0)",
                     currency: response.currency?.uppercased() ?? "",
                     amount: amount,
                     address: response.address)
    }
}

class AchExchangeWorker: BaseApiWorker<AchExchangeWorkerMapper> {
    override func getMethod() -> HTTPMethod {
        return .post
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(ExchangeEndpoints.achCreate)
    }
}
