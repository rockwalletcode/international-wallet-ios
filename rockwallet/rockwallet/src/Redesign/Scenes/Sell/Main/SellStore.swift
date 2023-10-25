//
//  SellStore.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import WalletKit

class SellStore: NSObject, BaseDataStore, SellDataStore {
    // MARK: - CreateTransactionDataStore
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    var sender: Sender?
    var proTransfer: String?
    
    // MARK: - ExchangeRateDataStore
    
    var quote: Quote?
    
    var fromCode: String { fromAmount?.currency.code ?? "" }
    var toCode: String { Constant.usdCurrencyCode }
    var isFromBuy: Bool = true
    var showTimer: Bool = false
    var accountId: String? { return ach?.id }
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode,
                     type: .sell(paymentMethod),
                     accountId: accountId)
    }
    
    // MARK: - PaymentMethodsDataStore

    var ach: PaymentCard?
    var selected: PaymentCard?
    var cards: [PaymentCard] = []
    
    // MARK: - SellDataStore
    
    var paymentMethod: PaymentCard.PaymentType? = .ach
    var exchangeType: ExchangeType? { return paymentMethod == .ach ? .sellAch : .sellCard }
    var availablePayments: [PaymentCard.PaymentType] = []
    var hasAchSellAccess: Bool { return UserManager.shared.profile?.kycAccessRights.hasAchSellAccess == true }
    var hasCardSellAccess: Bool { return UserManager.shared.profile?.kycAccessRights.hasCardSellAccess == true }
    
    var currencies: [Currency] = []
    var supportedCurrencies: [String]?
    var amount: Amount? {
        get {
            return fromAmount
        }
        set(value) {
            fromAmount = value
        }
    }
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let weeklyCardLimit = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.sellAllowanceWeekly),
              let weeklyAchLimit = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.sellAchAllowanceWeekly)
        else { return nil }
        
        let limitsString: NSMutableAttributedString
        
        let minTextFormatted = "\(minText) \(Constant.usdCurrencyCode)"
        let cardMaxTextFormatted = "\(weeklyCardLimit) \(Constant.usdCurrencyCode)"
        let achMaxTextFormatted = "\(weeklyAchLimit) \(Constant.usdCurrencyCode)"
        
        switch paymentMethod {
        case .card:
            let limitsText = L10n.Sell.sellLimits1(minTextFormatted, cardMaxTextFormatted)
            limitsString = NSMutableAttributedString(string: limitsText + "\n\n" + L10n.Buy.BuyLimits.increase)
            
        case .ach:
            let limitsText = L10n.Sell.sellLimits(minTextFormatted, achMaxTextFormatted)
            limitsString = NSMutableAttributedString(string: limitsText)
            
        default:
            limitsString = .init(string: "")
        }
        
        return limitsString
    }
    
    var fromAmount: Amount?
    var toAmount: Decimal? { return fromAmount?.fiatValue }
    
    var fromRate: Decimal?
    
    var exchange: Exchange?
    
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction?
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
    
    var fromFeeAmount: Amount? {
        guard let value = fromFeeBasis,
              let currency = currencies.first(where: { $0.code == value.fee.currency.code.uppercased() }) else {
            return nil
        }
        return .init(cryptoAmount: value.fee, currency: currency)
    }
    
    var isFormValid: Bool {
        guard let amount = fromAmount,
              amount.tokenValue > 0,
              selected != nil
        else {
            return false
        }
        
        if ach != nil && ach?.status != .statusOk {
            return false
        } else {
            return true
        }
    }
}
