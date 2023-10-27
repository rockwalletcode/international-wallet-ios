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
                let fromCurrency: Currency? = self?.dataStore?.currencies.first
                self?.dataStore?.selectedCurrency = fromCurrency
                
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
    
    func setAssetSelectionData(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.amount = .zero(currency)
            dataStore?.selectedCurrency = currency
            
            dataStore?.fromAmount = .zero(currency)
            guard let fromCurrency = dataStore?.fromAmount else { return }
            
            setPresentAmountData(handleErrors: false)
            
            presenter?.presentData(actionResponse: .init(item: Models.Item(fromCurrency)))
        }
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.amount = .zero(currency)
            
//            guard viewAction.didFinish else { return }
//            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
//                self?.setPresentAmountData(handleErrors: false)
//            })
//
//            return
        } else if viewAction.card != nil {
            guard viewAction.didFinish else { return }
            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
                self?.setPresentAmountData(handleErrors: false)
            })
            
            return
        }
        
        let fiat = ExchangeFormatter.current.number(from: viewAction.toFiatValue ?? "")?.decimalValue
        
//        guard let rate = dataStore?.quote?.exchangeRate,
//              let toCurrency = dataStore?.amount?.currency else {
//            setPresentAmountData(handleErrors: true)
//            return
//        }
        
        let to: Amount
        
        if let value = viewAction.fromTokenValue,
           let crypto = ExchangeFormatter.current.number(from: value)?.decimalValue,
           let currency = dataStore?.selectedCurrency {
            to = .init(decimalAmount: crypto, isFiat: false, currency: currency, exchangeRate: 1 / 5)
        } else if let value = viewAction.fromFiatValue,
                  let fiat = ExchangeFormatter.current.number(from: value)?.decimalValue,
                  let currency = dataStore?.selectedCurrency {
            to = .init(decimalAmount: fiat, isFiat: true, currency: currency, exchangeRate: 1 / 5)
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
        presenter?.presentConfirmation(actionResponse: .init(fromCurrency: dataStore?.selectedCurrency,
                                                             fromAmount: dataStore?.amount,
                                                             toAmount: dataStore?.toAmount,
                                                             quote: dataStore?.quote,
                                                             fromFee: dataStore?.fromFeeAmount,
                                                             toFee: dataStore?.toFeeAmount,
                                                             isDeposit: dataStore?.isDeposit))
    }
    
    func confirm(viewAction: Models.Confirm.ViewAction) {
        guard let from = dataStore?.amount?.tokenValue,
        let isDeposit = dataStore?.isDeposit else { return }
        
        let formatter = ExchangeFormatter.current
        formatter.locale = Locale(identifier: Constant.usLocaleCode)
        formatter.usesGroupingSeparator = false
        let fromTokenValue = formatter.string(for: from) ?? ""
        let destinationAddress: String
        
        if !isDeposit {
            destinationAddress = dataStore?.proSupportedCurrencies?.first(where: { $0.currency == dataStore?.selectedCurrency?.code.lowercased() })?.address ?? ""
            prepareFees(viewAction: .init(), completion: { [weak self] in
                self?.createTransaction(viewAction: .init(currencies: self?.dataStore?.currencies,
                                                          fromAmount: self?.dataStore?.amount,
                                                          proTransfer: self?.dataStore?.selectedCurrency?.name,
                                                          address: destinationAddress), completion: { [weak self] error in
                    if let error {
                        self?.presenter?.presentError(actionResponse: .init(error: error))
                    } else {
                        self?.presenter?.presentConfirm(actionResponse: .init(isDeposit: self?.dataStore?.isDeposit))
                    }
                })
            })
        } else {
            destinationAddress = Store.state.orderedWallets.first(where: { $0.currency.code == dataStore?.selectedCurrency?.code })?.receiveAddress ?? ""
            
            let data = WithdrawalRequestData(amount: fromTokenValue, address: destinationAddress, asset: dataStore?.selectedCurrency?.code.lowercased())
            WithdrawalWorker().execute(requestData: data) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.presentConfirm(actionResponse: .init(isDeposit: self?.dataStore?.isDeposit))
                    
                case .failure(let error):
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                }
            }
        }
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
        dataStore?.currencies = Store.state.currenciesProWallet.filter { cur in currencies.map { $0.lowercased() }.contains(cur.code.lowercased()) }
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
        presenter?.presentAmount(actionResponse: .init(fromAmount: dataStore?.fromAmount,
                                                       senderValidationResult: dataStore?.senderValidationResult,
                                                       fromFeeBasis: dataStore?.fromFeeBasis,
                                                       fromFeeAmount: dataStore?.fromFeeAmount,
                                                       fromFeeCurrency: dataStore?.sender?.wallet.feeCurrency,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
    }
}
