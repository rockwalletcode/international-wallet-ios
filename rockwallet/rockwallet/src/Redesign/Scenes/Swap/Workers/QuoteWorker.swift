// 
//  QuoteWorker.swift
//  breadwallet
//
//  Created by Rok on 04/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum QuoteType: Equatable {
    case swap
    case sell
    case buy(PaymentCard.PaymentType?)
    
    var value: String {
        switch self {
        case .swap:
            return "SWAP"
        case .buy(let paymentType):
            switch paymentType {
            case .card:
                return "BUY_CARD"
            case .ach:
                return "BUY_ACH"
            default:
                return ""
            }
        case .sell:
            return "SELL_ACH"
        }
    }
}

struct QuoteRequestData: RequestModelData {
    var from: String?
    var to: String?
    var type: QuoteType = .swap
    var accountId: String?
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "from": from,
            "to": to,
            "type": type.value,
            "account_id": accountId
        ]
        return params.compactMapValues { $0 }
    }
}

struct QuoteModelResponse: ModelResponse {
    var quoteId: Int
    var exchangeRate: Decimal
    var barTime: Double
    var timestamp: Double
    
    var minimumValue: Decimal
    var maximumValue: Decimal
    var minimumValueUsd: Decimal
    var maximumValueUsd: Decimal
    
    struct Fee: Codable {
        var feeCurrency: String?
        var rate: Decimal?
        var depositRate: Decimal?
    }
    
    struct AchFee: Codable {
        var achFeeFixedUsd: Decimal?
        var achFeePercentage: Decimal?
        var achSellFeePercentage: Decimal?
    }
    
    var fromFeeCurrency: Fee?
    var toFeeCurrency: Fee?
    var fromFee: Decimal?
    var toFee: Decimal?
    var buyFees: Decimal?
    var achFees: AchFee?
    var isMinimumImpactedByWithdrawal: Bool?
    var instantAch: InstantAchQuote?
    var type: String?
}

struct Quote {
    var quoteId: Int
    var exchangeRate: Decimal
    var timestamp: Double
    
    var minimumValue: Decimal
    var maximumValue: Decimal
    var minimumUsd: Decimal
    var maximumUsd: Decimal
    var fromFeeRate: Decimal?
    var toFeeRate: Decimal?
    var fromFee: EstimateFee?
    var toFee: EstimateFee?
    var buyFee: Decimal?
    var buyFeeUsd: Decimal?
    var isMinimumImpactedByWithdrawal: Bool?
    var instantAch: InstantAchQuote?
}

struct InstantAchQuote: Codable {
    var limitInToCurrency: Decimal?
    var limitUsd: Decimal?
    var feePercentage: Decimal?
}

struct EstimateFee: Model {
    var fee: Decimal
    var feeRate: Decimal?
    var currency: String
}

class QuoteMapper: ModelMapper<QuoteModelResponse, Quote> {
    override func getModel(from response: QuoteModelResponse?) -> Quote? {
        guard let response = response else { return nil }

        var fromFee: EstimateFee?
        if let currency = response.fromFeeCurrency?.feeCurrency,
           let value = response.fromFee {
            fromFee = .init(fee: value, currency: currency)
        }
        
        var toFee: EstimateFee?
        if let currency = response.toFeeCurrency?.feeCurrency,
           let value = response.toFee {
            toFee = .init(fee: value, feeRate: response.toFeeCurrency?.depositRate ?? 0, currency: currency)
        }
        
        return .init(quoteId: response.quoteId,
                     exchangeRate: response.exchangeRate,
                     timestamp: response.timestamp,
                     minimumValue: response.minimumValue,
                     maximumValue: response.maximumValue,
                     minimumUsd: response.minimumValueUsd,
                     maximumUsd: response.maximumValueUsd,
                     fromFeeRate: response.fromFeeCurrency?.rate,
                     toFeeRate: response.toFeeCurrency?.rate,
                     fromFee: fromFee,
                     toFee: toFee,
                     buyFee: response.buyFees ?? (response.type == QuoteType.sell.value ? response.achFees?.achSellFeePercentage : response.achFees?.achFeePercentage),
                     buyFeeUsd: response.achFees?.achFeeFixedUsd,
                     isMinimumImpactedByWithdrawal: response.isMinimumImpactedByWithdrawal,
                     instantAch: response.instantAch)
    }
}

class QuoteWorker: BaseApiWorker<QuoteMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? QuoteRequestData),
              let from = urlParams.from,
              let to = urlParams.to else { return "" }
        
        var url: String
        
        if let code = urlParams.secondFactorCode {
            url = APIURLHandler.getUrl(ExchangeEndpoints.quoteSecondFactorCode, parameters: from, to, urlParams.type.value, code)
        } else if let code = urlParams.secondFactorBackup {
            url = APIURLHandler.getUrl(ExchangeEndpoints.quoteSecondFactorBackup, parameters: from, to, urlParams.type.value, code)
        } else {
            url = APIURLHandler.getUrl(ExchangeEndpoints.quote, parameters: from, to, urlParams.type.value)
        }
        
        if let accountId = urlParams.accountId {
            url.append(String(format: "&account_id=%@", accountId))
        }
        
        return url
    }
}
