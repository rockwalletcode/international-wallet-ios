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
import WalletKit

protocol AssetViewActions: BaseViewActions, FetchViewActions {
    func getExchangeRate(viewAction: AssetModels.ExchangeRate.ViewAction, completion: (() -> Void)?)
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?)
    func prepareFees(viewAction: AssetModels.Fee.ViewAction, completion: (() -> Void)?)
    func setAmount(viewAction: AssetModels.Asset.ViewAction)
    func prepareCurrencies(viewAction: AssetModels.Item)
}

protocol AssetActionResponses: BaseActionResponses, FetchActionResponses {
    func presentExchangeRate(actionResponse: AssetModels.ExchangeRate.ActionResponse, completion: (() -> Void)?)
    func handleError(actionResponse: AssetModels.Asset.ActionResponse) -> Bool
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse)
}

protocol AssetResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    var tableView: ContentSizedTableView { get set }
    var continueButton: FEButton { get set }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>?
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>?
    
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?)
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay)
}

protocol AssetDataStore: BaseDataStore, FetchDataStore, TwoStepDataStore {
    var limits: NSMutableAttributedString? { get }
    var fromCode: String { get }
    var toCode: String { get }
    var quoteRequestData: QuoteRequestData { get }
    var quote: Quote? { get set }
    var showTimer: Bool { get set }
    var isFromBuy: Bool { get set }
    var currencies: [Currency] { get set }
    var supportedCurrencies: [String]? { get set }
    var amount: Amount? { get set }
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
    
    func prepareCurrencies(viewAction: AssetModels.Item) {
        guard let type = viewAction.type else { return }
        
        let currencies = SupportedCurrenciesManager.shared.supportedCurrencies(type: type)
        
        dataStore?.supportedCurrencies = currencies
        dataStore?.currencies = Store.state.currencies.filter { cur in currencies.map { $0.lowercased() }.contains(cur.code.lowercased()) }
    }
    
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {}
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {}
    
    func prepareFees(viewAction: AssetModels.Fee.ViewAction, completion: (() -> Void)?) {}
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
                text = String(format: Constant.exchangeFormat, to, ExchangeNumberFormatter().string(for: 1 / quote.exchangeRate) ?? "", from.uppercased())
            } else {
                text = String(format: Constant.exchangeFormat, from.uppercased(), ExchangeNumberFormatter().string(for: quote.exchangeRate) ?? "", to)
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
        let balance = actionResponse.isDeposit ? actionResponse.balanceAmount : from.currency.state?.balance
        let fromCode = from.currency.code.uppercased()
        let toCode = Constant.usdCurrencyCode
        var senderValidationResult = actionResponse.senderValidationResult ?? .ok
        var error: ExchangeErrors?
        
        let isBuy = self.isKind(of: BuyPresenter.self)
        let isSell = self.isKind(of: SellPresenter.self)
        let isSwap = self.isKind(of: SwapPresenter.self)
        let isTransfer = self.isKind(of: TransferFundsPresenter.self)
        
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
            
            if let balance, from > balance {
                senderValidationResult = .insufficientFunds
                error = ExchangeErrors.insufficientFunds(currency: fromCode)
                // ETH feeBasis on insufficient gas includes from + feeAmount
            } else if from.currency.isERC20Token || from.currency.isEthereum,
                      feeAmount > feeCurrencyWalletBalance {
                senderValidationResult = .insufficientGas
            } else if from.currency == feeAmount.currency, let balance, from + feeAmount > balance {
                senderValidationResult = .insufficientGas
            }
        }
        
        guard !isTransfer else { // TODO: Update this if we need some other error messages for transfer funds
            if error != nil {
                presentError(actionResponse: .init(error: error))
            }
            
            return error != nil
        }
        
        if actionResponse.fromFeeBasis?.fee == nil && (isSwap || isSell) {
            switch senderValidationResult {
            case .insufficientFunds:
                error = ExchangeErrors.insufficientFunds(currency: fromCode)
                
            default:
                error = ExchangeErrors.noFees
            }
            
        } else if case .insufficientFunds = senderValidationResult {
            error = ExchangeErrors.insufficientFunds(currency: fromCode)
            
        } else if case .insufficientGas = senderValidationResult {
            let value = actionResponse.fromFeeAmount?.tokenValue ?? quote?.fromFee?.fee ?? 0
            
            if from.currency.isERC20Token {
                error = ExchangeErrors.insufficientGasERC20(currency: fromCode, balance: value)
                
            } else if actionResponse.fromFeeBasis?.fee != nil {
                error = ExchangeErrors.balanceTooLow(balance: value, currency: fromCode)
                
            }
            
        } else if quote == nil {
            error = ExchangeErrors.noQuote(from: fromCode, to: toCode)
            
        } else if ExchangeManager.shared.canSwap(from.currency) == false && isSwap {
            error = ExchangeErrors.pendingSwap
        } else if XRPBalanceValidator.validate(balance: from.currency.state?.balance, amount: from, currency: from.currency) != nil {
            error = ExchangeErrors.xrpErrorMessage
        } else {
            let fiat = from.fiatValue.round(to: 2)
            let token = from.tokenValue
            
            let minimumValue = quote?.minimumValue ?? 0
            let minimumUsd = quote?.minimumUsd.round(to: 2) ?? 0
            
            var reason: BaseInfoModels.FailureReason = .swap
            let limits = quote?.currentExchangeLimits?.sorted(by: { $0.interval?.priorityOrder ?? 0 < $1.interval?.priorityOrder ?? 0 }) ?? []
            
            if isBuy && actionResponse.type == .card {
                reason = .buyCard(nil)
            } else if isBuy && actionResponse.type == .ach {
                reason = .buyAch(nil, nil)
            } else if isSell {
                reason = .sell
            } else if isSwap {
                reason = .swap
            }
            
            switch fiat {
            case _ where fiat <= 0:
                // Fiat value is or below 0
                
                error = nil
                
            case _ where !limits.filter({ fiat > $0.limit ?? 0 }).isEmpty:
                // Over limit
                
                let limit = limits.first(where: { fiat > $0.limit ?? 0 })
                
                error = ExchangeErrors.tooHigh(interval: limit?.interval ?? .unknown, amount: limit?.limit ?? 0, currency: toCode, reason: reason)
                
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
                           Self.DataStore: AssetDataStore,
                           Self.ViewActions: AssetViewActions {
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?) {
        if let cell = getRateAndTimerCell(), let rateAndTimer = responseDisplay.rateAndTimer {
            cell.wrappedView.invalidate()
            
            cell.wrappedView.setup(with: rateAndTimer)
            cell.wrappedView.completion = { [weak self] in
                self?.interactor?.getExchangeRate(viewAction: .init(getFees: self?.dataStore?.isFromBuy == false), completion: {})
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
