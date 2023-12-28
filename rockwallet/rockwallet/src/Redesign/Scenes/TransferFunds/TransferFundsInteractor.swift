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
        dataStore?.currencies = Store.state.currenciesProWallet.filter { cur in Store.state.currencies.map { $0.code.lowercased() }.contains(cur.code.lowercased()) }
        
        let selectedCurrency: Currency? = dataStore?.currencies.first
        dataStore?.selectedCurrency = selectedCurrency
        
        guard let selectedCurrency else { return }
        
        dataStore?.fromAmount = .zero(selectedCurrency)
        guard let fromCurrency = dataStore?.fromAmount else { return }
        
        let balance = dataStore?.currencies.compactMap {
            let balanceText = String(format: Constant.currencyFormat,
                                      ExchangeFormatter.current.string(for: $0.state?.balance?.tokenValue) ?? "",
                                      $0.code.uppercased())
            
            return balanceText
        }
        
        dataStore?.balance = balance?.first
        presenter?.presentData(actionResponse: .init(item: Models.Item(amount: fromCurrency,
                                                                             balance: dataStore?.balance)))
        getProSupportedCurrencies()
        getWithdrawalFixedFees()
    }
    
    func setAssetSelectionData(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.amount = .zero(currency)
            dataStore?.selectedCurrency = currency
            
            dataStore?.fromAmount = .zero(currency)
            guard let fromCurrency = dataStore?.fromAmount else { return }
            
            setPresentAmountData(handleErrors: false)
            
            dataStore?.balance = viewAction.balanceValue
            
            presenter?.presentData(actionResponse: .init(item: Models.Item(amount: fromCurrency, balance: viewAction.balanceValue)))
        }
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        guard let currency = dataStore?.selectedCurrency,
              let currentRate = currency.state?.currentRate,
              let isDeposit = dataStore?.isDeposit else {
            return
        }
        
        if let value = viewAction.fromTokenValue,
                  let crypto = ExchangeFormatter.current.number(from: value)?.decimalValue {
            dataStore?.fromAmount = .init(decimalAmount: crypto, isFiat: false, currency: currency, exchangeRate: Decimal(currentRate.rate))
            
        } else if let value = viewAction.fromFiatValue,
                  let fiat = ExchangeFormatter.current.number(from: value)?.decimalValue {
            dataStore?.fromAmount = .init(decimalAmount: fiat, isFiat: true, currency: currency, exchangeRate: Decimal(currentRate.rate))
            
        } else if viewAction.didFinish {
            guard !isDeposit else {
                setPresentAmountData(handleErrors: handleWithdrawErrors())
                return
            }
            prepareFees(viewAction: .init(), completion: {})
            
        } else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        dataStore?.from = dataStore?.fromAmount?.fiatValue
        setPresentAmountData(handleErrors: false)
    }
    
    func navigateAssetSelector(viewAction: Models.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init(proBalancesData: dataStore?.proBalancesData,
                                                                      isDeposit: dataStore?.isDeposit ?? false))
    }
    
    func showConfirmation(viewAction: Models.ShowConfirmDialog.ViewAction) {
        guard let isDeposit = dataStore?.isDeposit else { return }
        
        let fromFee = isDeposit ? dataStore?.fromFixedFeeAmount : dataStore?.fromFeeAmount
        presenter?.presentConfirmation(actionResponse: .init(fromCurrency: dataStore?.selectedCurrency,
                                                             fromAmount: dataStore?.fromAmount,
                                                             fromFee: fromFee,
                                                             isDeposit: dataStore?.isDeposit))
    }
    
    func confirm(viewAction: Models.Confirm.ViewAction) {
        guard let from = dataStore?.fromAmount?.tokenValue,
        let isDeposit = dataStore?.isDeposit else { return }
        
        let formatter = ExchangeFormatter.current
        formatter.locale = Locale(identifier: Constant.usLocaleCode)
        formatter.usesGroupingSeparator = false
        let fromTokenValue = formatter.string(for: from) ?? ""
        let destinationAddress: String
        
        if !isDeposit {
            destinationAddress = dataStore?.proSupportedCurrencies?.first(where: { $0.currency == dataStore?.selectedCurrency?.code.lowercased() })?.address ?? ""
            createTransaction(viewAction: .init(currencies: dataStore?.currencies,
                                                fromAmount: dataStore?.fromAmount,
                                                proTransfer: dataStore?.selectedCurrency?.code,
                                                address: destinationAddress), completion: { [weak self] error in
                if let error {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                } else {
                    self?.presenter?.presentConfirm(actionResponse: .init(isDeposit: self?.dataStore?.isDeposit))
                }
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
        guard let from = dataStore?.fromAmount else {
            return
        }
        
        generateSender(viewAction: .init(fromAmountCurrency: from.currency))
        
        getFees(viewAction: .init(fromAmount: from), completion: { [weak self] _ in
            self?.setPresentAmountData(handleErrors: true)
            
            completion?()
        })
    }
    
    func handleWithdrawErrors() -> Bool {
        guard let balance = dataStore?.proBalancesData?.getProBalance(code: dataStore?.selectedCurrency?.code ?? ""),
              let amount = dataStore?.fromAmount?.tokenValue else { return false }
        
        guard amount <= balance else {
            presenter?.presentError(actionResponse: .init(error:
                                                            GeneralError(errorMessage: L10n.ErrorMessages.notEnoughBalance(dataStore?.selectedCurrency?.code ?? ""))))
            return true
        }
        
        return false
    }
    
    func switchPlaces(viewAction: Models.SwitchPlaces.ViewAction) {
        guard let from = dataStore?.fromAmount?.currency,
              let isDeposit = dataStore?.isDeposit else { return }
        
        dataStore?.fromAmount = .zero(from)
        dataStore?.isDeposit = !isDeposit
        
        let currency = Store.state.currencies.first(where: { $0.code == from.code })
        if isDeposit {
            dataStore?.balance = String(format: Constant.currencyFormat,
                                        ExchangeFormatter.current.string(for: currency?.state?.balance?.tokenValue) ?? "",
                                        currency?.code.uppercased() ?? "")
        } else {
            let balancePro = dataStore?.proBalancesData?.getProBalance(code: currency?.code ?? "") ?? 0
            dataStore?.balance = String(format: Constant.currencyFormat,
                                        ExchangeFormatter.current.string(for: balancePro) ?? "",
                                        currency?.code.uppercased() ?? "")
        }
        
        setPresentAmountData(handleErrors: false)
        
        presenter?.presentSwitchPlaces(actionResponse: .init(isDeposit: isDeposit))
    }
    
    // MARK: - Aditional helpers
    
    func getWithdrawalFixedFees() {
        WithdrawalFixedFeesWorker().execute { [weak self] result in
            switch result {
            case .success(let response):
                self?.dataStore?.fixedFees = response
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func getProSupportedCurrencies() {
        ProSupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.dataStore?.proSupportedCurrencies = currencies
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        guard let currency = dataStore?.selectedCurrency,
              let isDeposit = dataStore?.isDeposit else {
            return
        }
        
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
        var balance: Amount?
        if isDeposit {
            balance = Amount(decimalAmount: dataStore?.proBalancesData?.getProBalance(code: currency.code) ?? 0, isFiat: true, currency: currency)
        }
        
        presenter?.presentAmount(actionResponse: .init(fromAmount: dataStore?.fromAmount,
                                                       senderValidationResult: dataStore?.senderValidationResult,
                                                       fromFeeBasis: dataStore?.fromFeeBasis,
                                                       fromFeeAmount: dataStore?.fromFeeAmount,
                                                       fromFeeCurrency: dataStore?.sender?.wallet.feeCurrency,
                                                       balanceValue: dataStore?.balance,
                                                       balanceAmount: balance,
                                                       isDeposit: isDeposit,
                                                       handleErrors: handleErrors && isNotZero))
    }
}
