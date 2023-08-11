//
//  ExchangeDetailsWorker.swift
//  breadwallet
//
//  Created by Rok on 21/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ExchangeDetailsResponseData: ModelResponse {
    struct SourceDestination: ModelResponse {
        var status: String?
        var currency: String?
        var currencyAmount: Decimal?
        var usdAmount: Decimal?
        var usdFee: Decimal?
        var instantUsdFee: Decimal?
        var transactionId: String?
        var paymentInstrument: PaymentCardsResponseData.PaymentInstrument?
        var feeRate: Decimal?
        var feeFixedRate: Decimal?
    }
    
    var orderId: Int?
    var status: String?
    var statusDetails: String?
    var source: SourceDestination?
    var destination: SourceDestination?
    var instantDestination: SourceDestination?
    var rate: Decimal?
    var timestamp: Int?
    var type: String?
}

struct ExchangeDetail: Model, Hashable {
    struct SourceDestination: Model, Hashable {
        enum Part: Int {
            case one = 1
            case two = 2
        }
        
        var status: TransactionStatus
        var currency: String
        var currencyAmount: Decimal
        var usdAmount: Decimal
        var usdFee: Decimal
        var instantUsdFee: Decimal?
        var transactionId: String?
        var paymentInstrument: PaymentCard?
        var feeRate: Decimal?
        var feeFixedRate: Decimal?
        var part: Part?
    }
    
    var orderId: Int
    var status: TransactionStatus
    var statusDetails: String
    var source: SourceDestination
    var destination: SourceDestination?
    var instantDestination: SourceDestination?
    var isHybridTransaction: Bool
    var part: SourceDestination.Part?
    var rate: Decimal
    var timestamp: Int
    var type: ExchangeType
}

class ExchangeDetailsMapper: ModelMapper<ExchangeDetailsResponseData, ExchangeDetail> {
    override func getModel(from response: ExchangeDetailsResponseData?) -> ExchangeDetail {
        let source = response?.source
        let sourceCard = response?.source?.paymentInstrument
        let destination = response?.destination
        let instantDestination = response?.instantDestination
        let sourceCardPaymentMethodStatus = PaymentCard.PaymentMethodStatus(rawValue: sourceCard?.paymentMethodStatus ?? "")
        let destinationCardPaymentMethodStatus = PaymentCard.PaymentMethodStatus(rawValue: destination?.paymentInstrument?.paymentMethodStatus ?? "")
        
        let sourceData = ExchangeDetail
            .SourceDestination(status: .init(string: source?.status) ?? .failed,
                               currency: source?.currency?.uppercased() ?? "",
                               currencyAmount: source?.currencyAmount ?? 0,
                               usdAmount: source?.usdAmount ?? 0,
                               usdFee: source?.usdFee ?? 0,
                               instantUsdFee: source?.instantUsdFee ?? 0,
                               transactionId: source?.transactionId,
                               paymentInstrument: PaymentCard(type: PaymentCard.PaymentType(rawValue: sourceCard?.type ?? "") ?? .card,
                                                              id: sourceCard?.id ?? "",
                                                              fingerprint: sourceCard?.fingerprint ?? "",
                                                              expiryMonth: sourceCard?.expiryMonth ?? 0,
                                                              expiryYear: sourceCard?.expiryYear ?? 0,
                                                              scheme: PaymentCard.Scheme(rawValue: sourceCard?.scheme ?? "") ?? .none,
                                                              last4: sourceCard?.last4 ?? "",
                                                              accountName: sourceCard?.accountName ?? "",
                                                              status: PaymentCard.Status(rawValue: sourceCard?.status ?? "") ?? .none,
                                                              cardType: PaymentCard.CardType(rawValue: sourceCard?.cardType ?? "") ?? .none,
                                                              paymentMethodStatus: sourceCardPaymentMethodStatus ?? .none),
                               feeRate: source?.feeRate,
                               feeFixedRate: source?.feeFixedRate)
        let destinationData = ExchangeDetail
            .SourceDestination(status: .init(string: destination?.status) ?? .failed,
                               currency: destination?.currency?.uppercased() ?? "",
                               currencyAmount: destination?.currencyAmount ?? 0,
                               usdAmount: destination?.usdAmount ?? 0,
                               usdFee: destination?.usdFee ?? 0,
                               instantUsdFee: destination?.instantUsdFee,
                               transactionId: destination?.transactionId,
                               paymentInstrument: PaymentCard(type: PaymentCard.PaymentType(rawValue: destination?.paymentInstrument?.type ?? "") ?? .card,
                                                              id: destination?.paymentInstrument?.id ?? "",
                                                              fingerprint: destination?.paymentInstrument?.fingerprint ?? "",
                                                              expiryMonth: destination?.paymentInstrument?.expiryMonth ?? 0,
                                                              expiryYear: destination?.paymentInstrument?.expiryYear ?? 0,
                                                              scheme: PaymentCard.Scheme(rawValue: destination?.paymentInstrument?.scheme ?? "") ?? .none,
                                                              last4: destination?.paymentInstrument?.last4 ?? "",
                                                              accountName: destination?.paymentInstrument?.accountName ?? "",
                                                              status: PaymentCard.Status(rawValue: destination?.paymentInstrument?.status ?? "") ?? .none,
                                                              cardType: PaymentCard.CardType(rawValue: destination?.paymentInstrument?.cardType ?? "") ?? .none,
                                                              paymentMethodStatus: destinationCardPaymentMethodStatus ?? .none),
                               feeRate: destination?.feeRate,
                               feeFixedRate: destination?.feeFixedRate,
                               part: instantDestination == nil ? .one : .two)
        
        let instantDestinationData = ExchangeDetail
            .SourceDestination(status: .init(string: instantDestination?.status) ?? .failed,
                               currency: instantDestination?.currency?.uppercased() ?? "",
                               currencyAmount: instantDestination?.currencyAmount ?? 0,
                               usdAmount: instantDestination?.usdAmount ?? 0,
                               usdFee: instantDestination?.usdFee ?? 0,
                               instantUsdFee: instantDestination?.instantUsdFee,
                               transactionId: instantDestination?.transactionId,
                               feeRate: instantDestination?.feeRate,
                               feeFixedRate: instantDestination?.feeFixedRate,
                               part: instantDestination != nil ? .one : nil)
        
        return ExchangeDetail(orderId: Int(response?.orderId ?? 0),
                              status: .init(string: response?.status) ?? .failed,
                              statusDetails: response?.statusDetails ?? "",
                              source: sourceData,
                              destination: destinationData,
                              instantDestination: instantDestinationData,
                              isHybridTransaction: instantDestination != nil && destination != nil,
                              rate: response?.rate ?? 0,
                              timestamp: Int(response?.timestamp ?? 0),
                              type: ExchangeType(rawValue: response?.type ?? "") ?? .unknown)
    }
}

struct ExchangeDetailsRequestData: RequestModelData {
    var exchangeId: String?
    
    func getParameters() -> [String: Any] {
        let params = ["exchangeId": exchangeId]
        
        return params.compactMapValues { $0 }
    }
}

class ExchangeDetailsWorker: BaseApiWorker<ExchangeDetailsMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? ExchangeDetailsRequestData)?.exchangeId else { return "" }
        
        return APIURLHandler.getUrl(ExchangeEndpoints.details, parameters: urlParams)
    }
}
