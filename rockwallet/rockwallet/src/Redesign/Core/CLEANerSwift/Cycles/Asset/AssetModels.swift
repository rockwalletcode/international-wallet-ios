// 
//  AssetModels.swift
//  breadwallet
//
//  Created by Rok on 09/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

enum AssetModels {
    struct Item: Hashable {
        var type: PaymentCard.PaymentType?
        var achEnabled: Bool
    }
    
    struct Fee {
        struct ViewAction {}
    }
    
    enum Section: Sectionable {
        case segment
        case rateAndTimer
        case accountLimits
        case limitActions
        case paymentMethod
        case swapCard
        case transferFunds
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum Asset {
        struct ViewAction {
            var fromFiatValue: String?
            var fromTokenValue: String?
            var toFiatValue: String?
            var toTokenValue: String?
            
            var currency: String?
            var card: PaymentCard?
            var balanceValue: String?
            
            var didFinish: Bool = false
            var isDeposit: Bool = false
        }
        
        struct ActionResponse {
            var fromAmount: Amount?
            var toAmount: Amount?
            
            var card: PaymentCard?
            var type: PaymentCard.PaymentType?
            
            var fromFee: Amount?
            var toFee: Amount?
            
            var senderValidationResult: SenderValidationResult?
            var fromFeeBasis: TransferFeeBasis?
            var fromFeeAmount: Amount?
            var fromFeeCurrency: Currency?
            var quote: Quote?
            var balanceValue: String?
            var balanceAmount: Amount?
            var isDeposit = false
            
            var handleErrors = false
        }
        
        struct ResponseDisplay {
            var swapCurrencyViewModel: SwapCurrencyViewModel?
            var mainSwapViewModel: MainSwapViewModel?
            
            var cardModel: CardSelectionViewModel?
            
            var continueEnabled = false
            var rate: ExchangeRateViewModel?
            var limitActions: MultipleButtonsViewModel?
        }
    }
    
    enum ExchangeRate {
        struct ViewAction {
            let getFees: Bool
        }
        
        struct ActionResponse {
            var quote: Quote?
            var from: String?
            var to: String?
            var limits: NSMutableAttributedString?
            var showTimer: Bool?
            var isFromBuy: Bool?
        }
        
        struct ResponseDisplay {
            var rateAndTimer: ExchangeRateViewModel?
            var accountLimits: LabelViewModel?
        }
    }
    
    enum CoingeckoRate {
        struct ViewAction {
            var getFees: Bool = false
        }
    }
}
