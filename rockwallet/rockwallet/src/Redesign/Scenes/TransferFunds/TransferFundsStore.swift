//
//  TransferFundsStore.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit
import WalletKit

class TransferFundsStore: NSObject, BaseDataStore, TransferFundsDataStore {
    // MARK: - TransferFundsDataStore
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    var sender: Sender?
    var to: Decimal?
    var publicToken: String?
    var mask: String?
    var availablePayments: [PaymentCard.PaymentType] = []
    var limits: NSMutableAttributedString?
    var fromCode: String = ""
    var toCode: String = ""
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode,
                     type: .buy(paymentMethod))
    }
    var paymentMethod: PaymentCard.PaymentType?
    var showTimer: Bool = false
    var isFromBuy: Bool = false
    var secondFactorCode: String?
    var secondFactorBackup: String?
    var from: Decimal?
    var fromAmount: Amount?
    var toAmount: Amount?
    var quote: Quote?
    var currencies: [Currency] = []
    var supportedCurrencies: [String]?
    var amount: Amount? {
        get {
            return toAmount
        }
        set(value) {
            toAmount = value
        }
    }
    
    var keyStore: KeyStore?
    var coreSystem: CoreSystem?
    
    var fromFeeAmount: Amount? {
        guard let value = fromFeeBasis,
              let currency = currencies.first(where: { $0.code == value.fee.currency.code.uppercased() }) else {
            return nil
        }
        return .init(cryptoAmount: value.fee, currency: currency)
    }
    
    var toFeeAmount: Amount? {
        guard let value = quote?.toFee,
              let fee = ExchangeFormatter.current.string(for: value.fee),
              let currency = currencies.first(where: { $0.code == value.currency.uppercased() }) else {
            return nil
        }
        return .init(tokenString: fee, currency: currency)
    }

    // MARK: - Aditional helpers
}
