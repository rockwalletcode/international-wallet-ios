//
//  OrderPreviewStore.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class OrderPreviewStore: NSObject, BaseDataStore, OrderPreviewDataStore {
    // MARK: - CreateTransactionDataStore
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    var sender: Sender?
    var proTransfer: String?
    
    // MARK: - OrderPreviewDataStore
    var type: PreviewType?
    var to: Amount?
    var from: Decimal?
    var toCurrency: String?
    var card: PaymentCard?
    var quote: Quote?
    var networkFee: Amount? {
        guard let value = quote?.toFee,
              let fee = ExchangeFormatter.current.string(for: value.fee),
              let currency = Store.state.currencies.first(where: { $0.code == value.currency.uppercased() }) else {
            return nil
        }
        
        guard let rate = quote?.toFee?.feeRate else {
            return .init(tokenString: fee, currency: currency)
        }
        
        return .init(decimalAmount: value.fee, isFiat: false, currency: currency, exchangeRate: 1 / rate)
    }
    
    var cvv: String?
    var paymentReference: String?
    var paymentstatus: AddCard.Status?
    var availablePayments: [PaymentCard.PaymentType]?
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction?
    
    var isAchAccount: Bool {
        return card?.type == .ach
    }
    
    var achDeliveryType: OrderPreviewModels.AchDeliveryType? = .instant
    
    // MARK: - Additional helpers
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
}
