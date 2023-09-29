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
    
    func confirmTransfer(viewAction: Models.ConfirmTransfer.ViewAction) {
        presenter?.presentConfirmTransfer(actionResponse: .init())
    }
    
    func confirm(viewAction: Models.Confirm.ViewAction) {
        guard let currency = dataStore?.currencies.first(where: { $0.code == dataStore?.fromAmount?.currency.code }),
              let address = dataStore?.coreSystem?.wallet(for: currency)?.receiveAddress,
              let from = dataStore?.fromAmount?.tokenValue
        else { return }
        
        let formatter = ExchangeFormatter.current
        formatter.locale = Locale(identifier: Constant.usLocaleCode)
        formatter.usesGroupingSeparator = false
        
        let fromTokenValue = formatter.string(for: from) ?? ""
        let toTokenValue = formatter.string(for: dataStore?.toAmount?.tokenValue) ?? ""
        
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
                print(error)
//                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.failed(error: error)))
            }
        }
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
