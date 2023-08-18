//
//  SwapStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class SwapStore: NSObject, BaseDataStore, SwapDataStore {
    // MARK: - CreateTransactionDataStore
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    var sender: Sender?
    
    // MARK: - ExchangeRateDataStore
    
    var fromCode: String { fromAmount?.currency.code ?? "" }
    var toCode: String { toAmount?.currency.code ?? "" }
    var showTimer: Bool = true
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode)
    }
    
    // MARK: - SwapDataStore
    
    var fromAmount: Amount?
    var toAmount: Amount?
    var isFromBuy: Bool = false
    
    var quote: Quote?
    var fromRate: Decimal?
    var toRate: Decimal?
    
    var currencies: [Currency] = []
    var supportedCurrencies: [String]?
    var amount: Amount?
    
    var baseCurrencies: [String] = []
    var termCurrencies: [String] = []
    var baseAndTermCurrencies: [[String]] = []
    
    var exchange: Exchange?
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    
    var isMinimumImpactedByWithdrawalShown: Bool = false
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxText = ExchangeFormatter.fiat.string(for: quote.maximumUsd)
        else { return nil }
        
        return NSMutableAttributedString(string: L10n.Swap.swapLimits("\(minText) \(Constant.usdCurrencyCode)",
                                                                      "\(maxText) \(Constant.usdCurrencyCode)"))
    }
    
    // MARK: - Additional helpers
    
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
}
