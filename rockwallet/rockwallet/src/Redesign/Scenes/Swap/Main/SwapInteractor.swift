//
//  SwapInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class SwapInteractor: NSObject, Interactor, SwapViewActions {
    
    typealias Models = SwapModels
    
    var presenter: SwapPresenter?
    var dataStore: SwapStore?
    
    // MARK: - SwapViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let item = AssetModels.Item(type: .card,
                                    achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false)
        
        prepareCurrencies(viewAction: item)
        
        guard (dataStore?.supportedCurrencies ?? []).count > 1 else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        let fromCurrency: Currency? = dataStore?.fromAmount != nil ? dataStore?.fromAmount?.currency : dataStore?.currencies.first
        
        guard let fromCurrency,
              let toCurrency = dataStore?.currencies.first(where: { $0.code != fromCurrency.code }) else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        if dataStore?.fromAmount == nil {
            dataStore?.fromAmount = .zero(fromCurrency)
        }
        
        dataStore?.toAmount = .zero(toCurrency)
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(fromAmount: dataStore?.fromAmount,
                                                                       toAmount: dataStore?.toAmount)))
        setInitialData()
    }
    
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {
        guard let baseCurrency = dataStore?.fromAmount?.currency.coinGeckoId,
              let termCurrency = dataStore?.toAmount?.currency.coinGeckoId else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: dataStore?.fromCode, to: dataStore?.toCode)))
            return
        }
        
        let coinGeckoIds = [baseCurrency, termCurrency]
        let vsCurrency = Constant.usdCurrencyCode.lowercased()
        let resource = Resources.simplePrice(ids: coinGeckoIds,
                                             vsCurrency: vsCurrency,
                                             options: [.change]) { [weak self] (result: Result<[SimplePrice], CoinGeckoError>) in
            switch result {
            case .success(let data):
                self?.dataStore?.fromRate = Decimal(data.first(where: { $0.id == baseCurrency })?.price ?? 0)
                self?.dataStore?.toRate = Decimal(data.first(where: { $0.id == termCurrency })?.price ?? 0)
                
                guard viewAction.getFees else {
                    completion?()
                    
                    self?.setPresentAmountData(handleErrors: true)
                    
                    return
                }
                
                self?.prepareFees(viewAction: .init(), completion: completion)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
                completion?()
            }
        }
        
        CoinGeckoClient().load(resource)
    }
    
    func prepareFees(viewAction: AssetModels.Fee.ViewAction, completion: (() -> Void)?) {
        guard let from = dataStore?.fromAmount,
              let profile = UserManager.shared.profile else {
            return
        }
        
        generateSender(viewAction: .init(fromAmountCurrency: dataStore?.fromAmount?.currency))
        
        getFees(viewAction: .init(fromAmount: from, limit: profile.swapAllowanceLifetime), completion: { [weak self] _ in
            self?.setPresentAmountData(handleErrors: true)
            
            completion?()
        })
    }
    
    func switchPlaces(viewAction: SwapModels.SwitchPlaces.ViewAction) {
        guard let from = dataStore?.fromAmount?.currency,
              let to = dataStore?.toAmount?.currency else { return }
        
        dataStore?.fromAmount = .zero(to)
        dataStore?.toAmount = .zero(from)
        
        setInitialData()
    }
    
    private func setInitialData() {
        dataStore?.quote = nil
        dataStore?.fromRate = nil
        dataStore?.toRate = nil
        dataStore?.fromFeeBasis = nil
        dataStore?.isMinimumImpactedByWithdrawalShown = false
        
        presenter?.presentError(actionResponse: .init(error: nil))
        
        getExchangeRate(viewAction: .init(getFees: true), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
        })
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        guard let fromRate = dataStore?.fromRate, let toRate = dataStore?.toRate, fromRate > 0, toRate > 0 else {
            return
        }
        
        guard let fromCurrency = dataStore?.fromAmount?.currency,
              let toCurrency = dataStore?.toAmount?.currency else {
            presenter?.presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.ErrorMessages.noCurrencies)))
            return
        }
        
        let exchangeRate = dataStore?.quote?.exchangeRate ?? 1
        
        let toFeeRate = dataStore?.quote?.toFee?.feeRate ?? 1
        let toFee = (dataStore?.quote?.toFee?.fee ?? 0)
        
        let from: Amount
        let to: Amount
        
        if let fromCryptoAmount = viewAction.fromTokenValue,
           let fromCrypto = ExchangeFormatter.current.number(from: fromCryptoAmount)?.decimalValue {
            from = .init(decimalAmount: fromCrypto, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: (fromCrypto - toFee / toFeeRate) * exchangeRate, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let fromFiatAmount = viewAction.fromFiatValue,
                  let fromFiat = ExchangeFormatter.current.number(from: fromFiatAmount)?.decimalValue {
            from = .init(decimalAmount: fromFiat, isFiat: true, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: (from.tokenValue - toFee / toFeeRate) * exchangeRate, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let toCryptoAmount = viewAction.toTokenValue,
                  let toCrypto = ExchangeFormatter.current.number(from: toCryptoAmount)?.decimalValue {
            from = .init(decimalAmount: toCrypto / exchangeRate + toFee / toFeeRate, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: toCrypto, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let toFiatAmount = viewAction.toFiatValue,
                  let toFiat = ExchangeFormatter.current.number(from: toFiatAmount)?.decimalValue {
            to = .init(decimalAmount: toFiat, isFiat: true, currency: toCurrency, exchangeRate: toRate)
            from = .init(decimalAmount: to.tokenValue / exchangeRate + toFee / toFeeRate, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            
        } else {
            setPresentAmountData(handleErrors: true)
            
            return
        }
        
        dataStore?.fromAmount = from
        dataStore?.toAmount = to
        
        setPresentAmountData(handleErrors: false)
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero || !(dataStore?.toAmount?.tokenValue ?? 0).isZero
        
        presenter?.presentAmount(actionResponse: .init(fromAmount: dataStore?.fromAmount,
                                                       toAmount: dataStore?.toAmount,
                                                       fromFee: dataStore?.fromFeeAmount,
                                                       toFee: dataStore?.toFeeAmount,
                                                       senderValidationResult: dataStore?.senderValidationResult,
                                                       fromFeeBasis: dataStore?.fromFeeBasis,
                                                       fromFeeAmount: dataStore?.fromFeeAmount,
                                                       fromFeeCurrency: dataStore?.sender?.wallet.feeCurrency,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
    }
    
    func assetSelected(viewAction: SwapModels.SelectedAsset.ViewAction) {
        guard let from = dataStore?.fromAmount?.currency,
              let to = dataStore?.toAmount?.currency else { return }
        
        if let asset = viewAction.from,
           let from = dataStore?.currencies.first(where: { $0.code == asset }) {
            dataStore?.fromAmount = .zero(from)
            dataStore?.toAmount = .zero(to)
        }
        
        if let asset = viewAction.to,
           let to = dataStore?.currencies.first(where: { $0.code == asset }) {
            dataStore?.toAmount = .zero(to)
            dataStore?.fromAmount = .zero(from)
        }
        
        setInitialData()
    }
    
    func selectAsset(viewAction: SwapModels.Assets.ViewAction) {
        var from: [Currency]?
        var to: [Currency]?
        
        if viewAction.to == true {
            to = dataStore?.currencies.filter { $0.code != dataStore?.fromAmount?.currency.code }
        } else {
            from = dataStore?.currencies.filter { $0.code != dataStore?.toAmount?.currency.code }
        }
        
        presenter?.presentSelectAsset(actionResponse: .init(from: from, to: to))
    }
    
    func showConfirmation(viewAction: SwapModels.ShowConfirmDialog.ViewAction) {
        presenter?.presentConfirmation(actionResponse: .init(fromAmount: dataStore?.fromAmount,
                                                             toAmount: dataStore?.toAmount,
                                                             quote: dataStore?.quote,
                                                             fromFee: dataStore?.fromFeeAmount,
                                                             toFee: dataStore?.toFeeAmount))
    }
    
    func confirm(viewAction: SwapModels.Confirm.ViewAction) {
        guard let currency = dataStore?.currencies.first(where: { $0.code == dataStore?.toAmount?.currency.code }),
              let address = dataStore?.coreSystem?.wallet(for: currency)?.receiveAddress,
              let from = dataStore?.fromAmount?.tokenValue,
              let to = dataStore?.toAmount?.tokenValue else { return }
        
        let formatter = ExchangeFormatter.current
        formatter.locale = Locale(identifier: Constant.usLocaleCode)
        formatter.usesGroupingSeparator = false
        
        let fromTokenValue = formatter.string(for: from) ?? ""
        let toTokenValue = formatter.string(for: to) ?? ""
        
        let data = ExchangeRequestData(quoteId: dataStore?.quote?.quoteId,
                                       depositQuantity: fromTokenValue,
                                       withdrawalQuantity: toTokenValue,
                                       destination: address)
        
        ExchangeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.exchange = data
                self?.createTransaction(viewAction: .init(exchange: self?.dataStore?.exchange,
                                                          currencies: self?.dataStore?.currencies,
                                                          fromFeeAmount: self?.dataStore?.fromFeeAmount,
                                                          fromAmount: self?.dataStore?.fromAmount,
                                                          toAmountCode: self?.dataStore?.toAmount?.currency.code.uppercased()), completion: { [weak self] error in
                    if let error {
                        self?.presenter?.presentError(actionResponse: .init(error: error))
                    } else {
                        let from = self?.dataStore?.fromAmount?.currency.code
                        let to = self?.dataStore?.toAmount?.currency.code
                        
                        self?.presenter?.presentConfirm(actionResponse: .init(from: from,
                                                                              to: to,
                                                                              exchangeId: self?.dataStore?.exchange?.exchangeId))
                    }
                })
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.failed(error: error)))
            }
        }
    }
    
    func showAssetInfoPopup(viewAction: SwapModels.AssetInfoPopup.ViewAction) {
        presenter?.presentAssetInfoPopup(actionResponse: .init())
    }
    
    func showAssetSelectionMessage(viewAction: SwapModels.AssetSelectionMessage.ViewAction) {
        presenter?.presentAssetSelectionMessage(actionResponse: .init(from: dataStore?.fromAmount?.currency,
                                                                      to: dataStore?.toAmount?.currency,
                                                                      selectedDisabledAsset: viewAction.selectedDisabledAsset))
    }
    
    // MARK: - Additional helpers
    
}
