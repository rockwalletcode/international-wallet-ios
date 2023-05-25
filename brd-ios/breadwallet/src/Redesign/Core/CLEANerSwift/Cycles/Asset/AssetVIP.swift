// 
//  AsstetVIP.swift
//  breadwallet
//
//  Created by Rok on 09/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol AssetViewActions {
    func getExchangeRate(viewAction: AssetModels.ExchangeRate.ViewAction, completion: (() -> Void)?)
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?)
    func setAmount(viewAction: AssetModels.Asset.ViewAction)
}

protocol AssetActionResponses {
    func presentExchangeRate(actionResponse: AssetModels.ExchangeRate.ActionResponse, completion: (() -> Void)?)
    func handleError(actionResponse: AssetModels.Asset.ActionResponse) -> Bool
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse)
}

protocol AssetResponseDisplays {
    var tableView: ContentSizedTableView { get set }
    var continueButton: FEButton { get set }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>?
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>?
    
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?)
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay)
}

protocol AssetDataStore: NSObject, TwoStepDataStore {
    var limits: NSMutableAttributedString? { get }
    var fromCode: String { get }
    var toCode: String { get }
    var quoteRequestData: QuoteRequestData { get }
    var quote: Quote? { get set }
    var showTimer: Bool { get set }
    var isFromBuy: Bool { get set }
}

extension Interactor where Self: AssetViewActions,
                           Self.DataStore: AssetDataStore,
                           Self.ActionResponses: AssetActionResponses {
    func getExchangeRate(viewAction: AssetModels.ExchangeRate.ViewAction, completion: (() -> Void)?) {
        guard let fromCurrency = dataStore?.fromCode.uppercased(),
              let toCurrency = dataStore?.toCode.uppercased(),
              var data = dataStore?.quoteRequestData else { return }
        
        data.secondFactorCode = dataStore?.secondFactorCode
        data.secondFactorBackup = dataStore?.secondFactorBackup
        
        QuoteWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let quote):
                self?.dataStore?.quote = quote
                
                self?.presenter?.presentExchangeRate(actionResponse: .init(quote: quote,
                                                                           from: fromCurrency,
                                                                           to: toCurrency,
                                                                           limits: self?.dataStore?.limits,
                                                                           showTimer: self?.dataStore?.showTimer,
                                                                           isFromBuy: self?.dataStore?.isFromBuy), completion: {
                    if self?.dataStore?.isFromBuy == true {
                        completion?()
                    } else {
                        self?.getCoingeckoExchangeRate(viewAction: .init(getFees: viewAction.getFees), completion: completion)
                    }
                })
                
            case .failure:
                self?.dataStore?.quote = nil
                
                completion?()
                
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: fromCurrency,
                                                                                                  to: toCurrency)))
            }
        }
    }
    
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {}
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {}
}

extension Presenter where Self: AssetActionResponses,
                          Self.ResponseDisplays: AssetResponseDisplays {
    func presentExchangeRate(actionResponse: AssetModels.ExchangeRate.ActionResponse, completion: (() -> Void)?) {
        var exchangeRateViewModel: ExchangeRateViewModel
        if let from = actionResponse.from,
           let to = actionResponse.to,
           let quote = actionResponse.quote,
           let showTimer = actionResponse.showTimer,
           let isFromBuy = actionResponse.isFromBuy {
            var text: String
            if isFromBuy {
                text = String(format: "1 %@ = $%@ %@", to, ExchangeNumberFormatter().string(for: 1 / quote.exchangeRate) ?? "", from.uppercased())
            } else {
                text = String(format: "1 %@ = %@ %@", from.uppercased(), ExchangeNumberFormatter().string(for: quote.exchangeRate) ?? "", to)
            }
            
            exchangeRateViewModel = ExchangeRateViewModel(exchangeRate: text,
                                                          timer: TimerViewModel(till: quote.timestamp, repeats: false),
                                                          showTimer: showTimer)
        } else {
            exchangeRateViewModel = ExchangeRateViewModel(timer: nil, showTimer: false)
        }
        
        viewController?.displayExchangeRate(responseDisplay: .init(rateAndTimer: exchangeRateViewModel,
                                                                   accountLimits: .attributedText(actionResponse.limits)),
                                            completion: completion)
    }
    
    func handleError(actionResponse: AssetModels.Asset.ActionResponse) -> Bool {
        guard let from = actionResponse.fromAmount else { return true }
        
        let quote = actionResponse.quote
        let balance = from.currency.state?.balance
        let fromCode = from.currency.code.uppercased()
        let toCode = Constant.usdCurrencyCode
        let fromFee = actionResponse.fromFee
        var senderValidationResult = actionResponse.senderValidationResult ?? .ok
        var error: ExchangeErrors?
        
        let isBuy = self.isKind(of: BuyPresenter.self)
        let isSell = self.isKind(of: SellPresenter.self)
        let isSwap = self.isKind(of: SwapPresenter.self)
        
        if isSwap,
           let dataStore = (self as? SwapPresenter)?.viewController?.dataStore,
           dataStore.isMinimumImpactedByWithdrawalShown == false &&
            !actionResponse.handleErrors &&
            quote?.isMinimumImpactedByWithdrawal == true &&
            from.cryptoAmount.isZero &&
            actionResponse.toAmount?.cryptoAmount.isZero == true {
            error = ExchangeErrors.highFees
            presentError(actionResponse: .init(error: error))
            
            dataStore.isMinimumImpactedByWithdrawalShown = true
            
            return false
        } else if !actionResponse.handleErrors {
            return false
        }
        
        if let feeCurrency = actionResponse.fromFeeCurrency,
           let feeCurrencyWalletBalance = feeCurrency.wallet?.balance,
           let fee = actionResponse.fromFeeBasis?.fee {
            let feeAmount = Amount(cryptoAmount: fee, currency: feeCurrency)

            if feeCurrency.isEthereum, feeAmount > feeCurrencyWalletBalance {
                senderValidationResult = .insufficientGas
            }

            if from.currency == feeAmount.currency {
                if let balance, from + feeAmount > balance {
                    senderValidationResult = .insufficientGas
                }
            }
        }
        
        if case .insufficientFunds = senderValidationResult {
            let value = actionResponse.fromFeeAmount?.tokenValue ?? quote?.fromFee?.fee ?? 0
            error = ExchangeErrors.balanceTooLow(balance: value, currency: fromCode)
            
        } else if case .insufficientGas = senderValidationResult {
            if from.currency.isEthereum {
                error = ExchangeErrors.notEnoughEthForFee(currency: fromCode)
                
            } else if from.currency.isERC20Token {
                error = ExchangeErrors.insufficientGasERC20(currency: fromCode)
                
            } else if actionResponse.fromFeeBasis?.fee != nil {
                let value = actionResponse.fromFeeAmount?.tokenValue ?? quote?.fromFee?.fee ?? 0
                error = ExchangeErrors.balanceTooLow(balance: value, currency: fromCode)
                
            }
        } else if quote == nil {
            error = ExchangeErrors.noQuote(from: fromCode, to: toCode)
            
        } else if ExchangeManager.shared.canSwap(from.currency) == false && self.isKind(of: SwapPresenter.self) {
            error = ExchangeErrors.pendingSwap
            
        } else if let feeAmount = fromFee,
                  let feeWallet = feeAmount.currency.wallet,
                  feeAmount.currency.isEthereum && feeAmount > feeWallet.balance {
            error = ExchangeErrors.notEnoughEthForFee(currency: feeAmount.currency.code)
            
        } else if let profile = UserManager.shared.profile {
            let fiat = from.fiatValue.round(to: 2)
            let token = from.tokenValue
            
            let minimumValue = quote?.minimumValue ?? 0
            let minimumUsd = quote?.minimumUsd.round(to: 2) ?? 0
            let maximumUsd = quote?.maximumUsd.round(to: 2) ?? 0
            
            var lifetimeLimit: Decimal = 0
            var dailyLimit: Decimal = 0
            var perExchangeLimit: Decimal = 0
            var reason: BaseInfoModels.FailureReason = .swap
            
            if isBuy {
                lifetimeLimit = profile.buyAllowanceLifetime
                dailyLimit = profile.buyAllowanceDaily
                perExchangeLimit = profile.buyAllowancePerExchange
                reason = .buyCard(nil)
            } else if isSell {
                lifetimeLimit = profile.sellAllowanceLifetime
                dailyLimit = profile.sellAllowanceDaily
                perExchangeLimit = profile.sellAllowancePerExchange
                reason = .sell
            } else if isSwap {
                lifetimeLimit = profile.swapAllowanceLifetime
                dailyLimit = profile.swapAllowanceDaily
                perExchangeLimit = profile.swapAllowancePerExchange
                reason = .swap
            }
            
            switch fiat {
            case _ where fiat <= 0:
                // Fiat value is or below 0
                
                error = nil
                
            case _ where fiat > lifetimeLimit,
                _ where minimumUsd > lifetimeLimit:
                // Over lifetime limit
                
                error = ExchangeErrors.overLifetimeLimit(limit: lifetimeLimit)
                
            case _ where fiat > dailyLimit:
                // Over daily limit
                
                let level2 = ExchangeErrors.overDailyLimitLevel2(limit: dailyLimit)
                let level1 = ExchangeErrors.overDailyLimit(limit: dailyLimit)
                error = profile.status == .levelTwo(.levelTwo) ? level2 : level1
                
            case _ where fiat > perExchangeLimit:
                // Over exchange limit
                
                error = ExchangeErrors.overExchangeLimit
                
            case _ where fiat > maximumUsd,
                _ where minimumUsd > maximumUsd:
                // Over exchange limit
                
                error = ExchangeErrors.tooHigh(amount: maximumUsd, currency: toCode, reason: reason)
                
            case _ where fiat < minimumUsd:
                // Value below minimum Fiat
                
                error = ExchangeErrors.tooLow(amount: minimumUsd, currency: toCode, reason: reason)
                
            case _ where token < minimumValue && fiat >= minimumUsd:
                // Value below minimum crypto and fiat is equal or above minimum because of the fees
                
                if isSwap {
                    error = ExchangeErrors.networkFee
                }
                
            case _ where token < minimumValue:
                // Value below minimum crypto
                
                if isSwap {
                    error = ExchangeErrors.tooLow(amount: minimumValue, currency: toCode, reason: reason)
                }
                
            case _ where fiat > (balance?.fiatValue ?? 0):
                // Value higher than balance
                
                if isSell || isSwap {
                    let value = actionResponse.fromFeeAmount?.tokenValue ?? actionResponse.quote?.fromFee?.fee ?? 0
                    error = ExchangeErrors.balanceTooLow(balance: value, currency: actionResponse.fromFeeAmount?.currency.code.uppercased() ?? "")
                }
                
            default:
                // Remove error
                
                error = nil
            }
        }
        
        presentError(actionResponse: .init(error: error))
        
        return error != nil
    }
}

extension Controller where Self: AssetResponseDisplays,
                           Self.ViewActions: AssetViewActions {
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?) {
        if let cell = getRateAndTimerCell(), let rateAndTimer = responseDisplay.rateAndTimer {
            cell.wrappedView.invalidate()
            
            cell.wrappedView.setup(with: rateAndTimer)
            cell.wrappedView.completion = { [weak self] in
                self?.interactor?.getExchangeRate(viewAction: .init(getFees: false), completion: {})
            }
        }
        
        if let cell = getAccountLimitsCell(), let accountLimits = responseDisplay.accountLimits {
            cell.wrappedView.setup(with: accountLimits)
        }
        
        var vm = continueButton.viewModel
        vm?.enabled = responseDisplay.rateAndTimer?.exchangeRate != nil
        continueButton.setup(with: vm)
        
        completion?()
    }
    
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {}
}