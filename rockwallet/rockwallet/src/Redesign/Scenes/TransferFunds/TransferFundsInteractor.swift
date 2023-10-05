//
//  TransferFundsInteractor.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

class TransferFundsInteractor: NSObject, Interactor, TransferFundsViewActions {
    typealias Models = TransferFundsModels
    
    var presenter: TransferFundsPresenter?
    var dataStore: TransferFundsStore?
    
    // MARK: - TransferFundsViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let item = AssetModels.Item(type: .card,
                                    achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false)
        
        prepareCurrencies(viewAction: item)
        
        ProSupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.dataStore?.proSupportedCurrencies = currencies
                let fromCurrency: Currency? = self?.dataStore?.currencies.first(where: { $0.code.lowercased() == currencies?.first?.currency })
                
                guard let fromCurrency else {
                    self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
                    return
                }
                
                self?.dataStore?.fromAmount = .zero(fromCurrency)
                guard let fromCurrency = self?.dataStore?.fromAmount else {
                    self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
                    return
                }
                
                self?.presenter?.presentData(actionResponse: .init(item: Models.Item(fromCurrency)))
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.amount = .zero(currency)
            
            guard viewAction.didFinish else { return }
            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
                self?.setPresentAmountData(handleErrors: false)
            })
            
            return
        } else if viewAction.card != nil {
            guard viewAction.didFinish else { return }
            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
                self?.setPresentAmountData(handleErrors: false)
            })
            
            return
        }
        
        guard let rate = dataStore?.quote?.exchangeRate,
              let toCurrency = dataStore?.amount?.currency else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        let to: Amount
        
        if let fiat = ExchangeFormatter.current.number(from: viewAction.toFiatValue ?? "")?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: rate)
        } else if let crypto = ExchangeFormatter.current.number(from: viewAction.fromTokenValue ?? "")?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: rate)
        } else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        dataStore?.amount = to
        dataStore?.from = to.fiatValue
        
        setPresentAmountData(handleErrors: false)
    }
    
    func navigateAssetSelector(viewAction: Models.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init())
    }
    
    func showAssetSelectionMessage(viewAction: Models.AssetSelectionMessage.ViewAction) {
        presenter?.presentAssetSelectionMessage(actionResponse: .init())
    }
    
    func showConfirmation(viewAction: Models.ShowConfirmDialog.ViewAction) {
        presenter?.presentConfirmation(actionResponse: .init(fromAmount: dataStore?.fromAmount,
                                                             toAmount: dataStore?.toAmount,
                                                             quote: dataStore?.quote,
                                                             fromFee: dataStore?.fromFeeAmount,
                                                             toFee: dataStore?.toFeeAmount,
                                                             isDeposit: dataStore?.isDeposit))
    }
    
    func confirm(viewAction: Models.Confirm.ViewAction) {
        // TODO: add transaction api call
        presenter?.presentConfirm(actionResponse: .init())
    }
    
    func switchPlaces(viewAction: Models.SwitchPlaces.ViewAction) {
        guard let from = dataStore?.fromAmount?.currency,
              let isDeposit = dataStore?.isDeposit else { return }
        
        dataStore?.fromAmount = .zero(from)
        dataStore?.isDeposit = !isDeposit
        
        presenter?.presentSwitchPlaces(actionResponse: .init(isDeposit: isDeposit))
    }
    
    // MARK: - Aditional helpers
    
    func prepareCurrencies(viewAction: AssetModels.Item) {
        guard let type = viewAction.type else { return }
        
        let currencies = SupportedCurrenciesManager.shared.supportedCurrencies(type: type)
        
        dataStore?.supportedCurrencies = currencies
        dataStore?.currencies = Store.state.currencies.filter { cur in currencies.map { $0.lowercased() }.contains(cur.code.lowercased()) }
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
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
}
