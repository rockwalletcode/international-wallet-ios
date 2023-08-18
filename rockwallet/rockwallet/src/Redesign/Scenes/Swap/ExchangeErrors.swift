// 
//  ExchangeErrors.swift
//  breadwallet
//
//  Created by Rok on 19/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum ExchangeErrors: FEError {
    case noQuote(from: String?, to: String?)
    /// Param 1: amount, param 2 currency symbol
    case tooLow(amount: Decimal, currency: String, reason: BaseInfoModels.FailureReason)
    /// Param 1: amount, param 2 currency symbol
    case tooHigh(amount: Decimal, currency: String, reason: BaseInfoModels.FailureReason)
    /// Param 1: amount, param 2 currency symbol
    case balanceTooLow(balance: Decimal, currency: String)
    case insufficientGasERC20(currency: String, balance: Decimal)
    case insufficientFunds(currency: String)
    case overDailyLimit(limit: Decimal)
    case overLifetimeLimit(limit: Decimal)
    case overDailyLimitLevel2(limit: Decimal)
    case notEnoughEthForFee(balance: Decimal, currency: String)
    case failed(error: Error?)
    case supportedCurrencies(error: Error?)
    case noFees
    case networkFee
    case overExchangeLimit
    case pinConfirmation
    case pendingSwap
    case selectAssets
    case authorizationFailed
    case highFees
    case xrpErrorMessage
    
    var errorType: ServerResponse.ErrorType? {
        switch self {
        case .supportedCurrencies(let error):
            return (error as? NetworkingError)?.errorType
            
        default:
            return nil
        }
    }
    
    var errorMessage: String {
        switch self {
        case .insufficientGasERC20(let currency, let amount):
            return L10n.ErrorMessages.ethBalanceLowAddEthWithAmount(currency, ExchangeFormatter.current.string(for: amount) ?? "")
            
        case .balanceTooLow(let amount, let currency),
                .notEnoughEthForFee(let amount, let currency):
            return L10n.ErrorMessages.balanceTooLow(ExchangeFormatter.current.string(for: amount) ?? "", currency, currency)
            
        case .insufficientFunds(let currency):
            return L10n.ErrorMessages.notEnoughBalance(currency)
            
        case .tooLow(let amount, let currency, let reason):
            switch reason {
            case .buyCard, .buyAch, .sell:
                return L10n.ErrorMessages.amountTooLow(ExchangeFormatter.fiat.string(for: amount.doubleValue) ?? "", currency)
                
            case .swap:
                return L10n.ErrorMessages.amountTooLow(ExchangeFormatter.current.string(for: amount.doubleValue) ?? "", currency)
                
            default:
                return ""
            }
            
        case .tooHigh(let amount, let currency, let reason):
            switch reason {
            case .buyCard, .buyAch, .sell:
                return L10n.ErrorMessages.amountTooHigh(ExchangeFormatter.fiat.string(for: amount.doubleValue) ?? "", currency)
                
            case .swap:
                return L10n.ErrorMessages.swapAmountTooHigh(ExchangeFormatter.current.string(for: amount) ?? "", currency)
                
            default:
                return ""
                
            }
        case .overDailyLimit(let limit):
            return L10n.ErrorMessages.overDailyLimit(ExchangeFormatter.fiat.string(for: limit) ?? "")
            
        case .overLifetimeLimit(let limit):
            return L10n.ErrorMessages.overLifetimeLimit(ExchangeFormatter.fiat.string(for: limit) ?? "")
            
        case .overDailyLimitLevel2(let limit):
            return L10n.ErrorMessages.overLifetimeLimitLevel2(ExchangeFormatter.fiat.string(for: limit) ?? "")
            
        case .noFees:
            return L10n.ErrorMessages.noFees
            
        case .networkFee:
            return L10n.ErrorMessages.networkFee
            
        case .noQuote(let from, let to):
            let from = from ?? "/"
            let to = to ?? "/"
            return L10n.ErrorMessages.noQuoteForPair(from, to)
            
        case .overExchangeLimit:
            return L10n.ErrorMessages.overExchangeLimit
            
        case  .pinConfirmation:
            return L10n.ErrorMessages.pinConfirmationFailed
            
        case .failed(let error):
            return L10n.ErrorMessages.exchangeFailed(error?.localizedDescription ?? "")
            
        case .supportedCurrencies:
            return L10n.ErrorMessages.exchangesUnavailable
            
        case .pendingSwap:
            return L10n.ErrorMessages.pendingExchange
            
        case .selectAssets:
            return L10n.ErrorMessages.selectAssets
            
        case .authorizationFailed:
            return L10n.ErrorMessages.authorizationFailed
            
        case .highFees:
            return L10n.ErrorMessages.highWidrawalFee
            
        case .xrpErrorMessage:
            return L10n.ErrorMessages.Exchange.xrpMinimumReserve(Constant.xrpMinimumReserve)
        }
    }
}
