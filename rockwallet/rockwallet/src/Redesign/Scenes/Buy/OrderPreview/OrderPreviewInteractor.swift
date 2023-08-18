//
//  OrderPreviewInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class OrderPreviewInteractor: NSObject, Interactor, OrderPreviewViewActions {
    typealias Models = OrderPreviewModels

    var presenter: OrderPreviewPresenter?
    var dataStore: OrderPreviewStore?
    
    private var biometricStatusRetryCounter: Int = 0
    
    // MARK: - OrderPreviewViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.type != nil else { return }
        
        guard let reference = dataStore?.paymentReference else {
            let item: Models.Item = (type: dataStore?.type,
                                     to: dataStore?.to,
                                     from: dataStore?.from,
                                     quote: dataStore?.quote,
                                     networkFee: dataStore?.networkFee,
                                     card: dataStore?.card,
                                     isAchAccount: dataStore?.isAchAccount,
                                     achDeliveryType: dataStore?.achDeliveryType)
            presenter?.presentData(actionResponse: .init(item: item))
            return
        }
        
        let requestData = PaymentStatusRequestData(reference: reference)
        PaymentStatusWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.paymentstatus = data?.status
                guard data?.status.isSuccesful == true || data?.status.achPending == true else {
                    self?.presenter?.presentSubmit(actionResponse: .init(paymentReference: self?.dataStore?.paymentReference,
                                                                         previewType: self?.dataStore?.type,
                                                                         isAch: self?.dataStore?.isAchAccount,
                                                                         achDeliveryType: self?.dataStore?.achDeliveryType,
                                                                         failed: true,
                                                                         responseCode: data?.responseCode,
                                                                         errorDescription: data?.errorMessage))
                    return
                }
                
                self?.presenter?.presentSubmit(actionResponse: .init(paymentReference: self?.dataStore?.paymentReference,
                                                                     previewType: self?.dataStore?.type,
                                                                     isAch: self?.dataStore?.isAchAccount,
                                                                     achDeliveryType: self?.dataStore?.achDeliveryType,
                                                                     failed: false,
                                                                     responseCode: nil,
                                                                     errorDescription: nil))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showInfoPopup(viewAction: OrderPreviewModels.InfoPopup.ViewAction) {
        presenter?.presentInfoPopup(actionResponse: .init(isCardFee: viewAction.isCardFee, fee: dataStore?.quote?.buyFee))
    }
    
    func showCvvInfoPopup(viewAction: OrderPreviewModels.CvvInfoPopup.ViewAction) {
        presenter?.presentCvvInfoPopup(actionResponse: .init())
    }
    
    func submit(viewAction: OrderPreviewModels.Submit.ViewAction) {
        switch dataStore?.isAchAccount {
        case true:
            submitAchExchange()
            
        default:
            submitCardExchange()
        }
    }
    
    func checkTimeOut(viewAction: OrderPreviewModels.ExpirationValidations.ViewAction) {
        let isTimedOut = Date().timeIntervalSince1970 > (dataStore?.quote?.timestamp ?? 0) / 1000
        
        presenter?.presentTimeOut(actionResponse: .init(isTimedOut: isTimedOut))
    }
    
    func updateCvv(viewAction: OrderPreviewModels.CvvValidation.ViewAction) {
        dataStore?.cvv = viewAction.cvv
        let isValid = FieldValidator.validate(cvv: dataStore?.cvv)
        
        presenter?.presentCvv(actionResponse: .init(isValid: isValid))
    }
    
    func showTermsAndConditions(viewAction: OrderPreviewModels.TermsAndConditions.ViewAction) {
        guard let url = URL(string: Constant.termsAndConditions) else { return }
        presenter?.presentTermsAndConditions(actionResponse: .init(url: url))
    }
    
    func toggleTickbox(viewAction: OrderPreviewModels.Tickbox.ViewAction) {
        presenter?.presentToggleTickbox(actionResponse: .init(value: viewAction.value))
    }
    
    // MARK: - Additional helpers
    
    private func submitCardExchange() {
        guard let currency = dataStore?.to?.currency,
              let address = currency.wallet?.defaultReceiveAddress,
              let to = dataStore?.to?.tokenValue,
              let from = dataStore?.from else { return }
        
        let cryptoFormatter = ExchangeFormatter.current
        cryptoFormatter.locale = Locale(identifier: Constant.usLocaleCode)
        cryptoFormatter.usesGroupingSeparator = false
        
        let fiatFormatter = ExchangeFormatter.fiat
        fiatFormatter.locale = Locale(identifier: Constant.usLocaleCode)
        fiatFormatter.usesGroupingSeparator = false
        
        let depositQuantityBuy = from + (dataStore?.networkFee?.fiatValue ?? 0) + from * (dataStore?.quote?.buyFee ?? 1) / 100
        let depositQuantitySell = to
        let depositQuantity = dataStore?.type == .buy ? depositQuantityBuy : depositQuantitySell
        let formattedDepositQuantity = cryptoFormatter.string(from: depositQuantity as NSNumber) ?? ""
        
        let sellValue = from - from * (dataStore?.quote?.buyFee ?? 1) / 100
        let withdrawalQuantityBuy = to
        let withdrawalQuantitySell = sellValue
        let withdrawalQuantity = dataStore?.type == .buy ? withdrawalQuantityBuy : withdrawalQuantitySell
        let formattedWithdrawalQuantity = fiatFormatter.string(from: withdrawalQuantity as NSNumber) ?? ""
        
        let destination = dataStore?.type == .buy ? address : dataStore?.card?.id
        let sourceInstrumentId = dataStore?.type == .buy ? dataStore?.card?.id : nil
        
        let data = ExchangeRequestData(quoteId: dataStore?.quote?.quoteId,
                                       depositQuantity: formattedDepositQuantity,
                                       withdrawalQuantity: formattedWithdrawalQuantity,
                                       destination: destination,
                                       sourceInstrumentId: sourceInstrumentId,
                                       nologCvv: dataStore?.cvv?.description,
                                       secondFactorCode: dataStore?.secondFactorCode,
                                       secondFactorBackup: dataStore?.secondFactorBackup)
        
        ExchangeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let exchangeData):
                self?.dataStore?.createTransactionModel?.exchange = exchangeData
                self?.dataStore?.paymentReference = exchangeData?.paymentReference
                guard let redirectUrlString = exchangeData?.redirectUrl, let redirectUrl = URL(string: redirectUrlString) else {
                    guard self?.dataStore?.type == .sell else {
                        self?.getData(viewAction: .init())
                        return
                    }
                    
                    self?.handleSellExchange()
                    return
                }
                
                ExchangeManager.shared.reload()
                self?.presenter?.presentThreeDSecure(actionResponse: .init(url: redirectUrl))
                
            case .failure(let error):
                guard let store = self?.dataStore,
                      let quoteId = store.quote?.quoteId,
                      (error as? NetworkingError)?.errorType == .biometricAuthentication else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                self?.presenter?.presentVeriffLivenessCheck(actionResponse: .init(quoteId: String(quoteId), isBiometric: true))
            }
        }
    }
    
    func showAchInstantDrawer(viewAction: OrderPreviewModels.AchInstantDrawer.ViewAction) {
        presenter?.presentAchInstantDrawer(actionResponse: .init(quote: dataStore?.quote, to: dataStore?.to))
    }
    
    func checkBiometricStatus(viewAction: OrderPreviewModels.BiometricStatusCheck.ViewAction) {
        let requestData = BiometricStatusRequestData(quoteId: dataStore?.quote?.quoteId.description)
        BiometricStatusHelper.shared.checkBiometricStatus(requestData: requestData, resetCounter: viewAction.resetCounter) { [weak self] error in
            guard error == nil else {
                let error = error as? NetworkingError
                self?.presenter?.presentBiometricStatusFailed(actionResponse: .init(reason: error == .livenessCheckLimit ? .livenessCheckLimit : .veriffDeclined))
                return
            }
            
            guard self?.dataStore?.isAchAccount == true else {
                self?.submitCardExchange()
                return
            }
            
            self?.submitAchExchange()
        }
    }
    
    private func submitAchExchange() {
        let currency = dataStore?.to?.currency
        
        let cryptoFormatter = ExchangeFormatter.current
        cryptoFormatter.locale = Locale(identifier: Constant.usLocaleCode)
        cryptoFormatter.usesGroupingSeparator = false
        
        let fiatFormatter = ExchangeFormatter.fiat
        fiatFormatter.locale = Locale(identifier: Constant.usLocaleCode)
        fiatFormatter.usesGroupingSeparator = false
        
        let formattedDepositQuantity: String
        let formattedWithdrawalQuantity: String
        
        if dataStore?.type == .sell {
            let sellFee = 1 - ((dataStore?.quote?.buyFee ?? 0) / 100)
            let fromAmount = (dataStore?.from ?? 0) * sellFee
            
            formattedDepositQuantity = cryptoFormatter.string(for: dataStore?.to?.tokenValue ?? 0) ?? ""
            formattedWithdrawalQuantity = fiatFormatter.string(from: (fromAmount) as NSNumber) ?? ""
        } else {
            let achFee = dataStore?.quote?.buyFeeUsd ?? 0
            
            let buyFee = ((dataStore?.quote?.buyFee ?? 0) / 100) + 1
            let fromAmount = (dataStore?.from ?? 0) * buyFee
            let toAmount = (dataStore?.from?.doubleValue ?? 0) / (dataStore?.to?.rate?.rate ?? 0)
            
            let instantAchFee = (dataStore?.quote?.instantAch?.feePercentage ?? 0) / 100
            let instantAchLimit = dataStore?.quote?.instantAch?.limitUsd ?? 0
            let instantAchFeeUsd = instantAchLimit * instantAchFee * buyFee
            
            // If purchase value exceeds instant ach limit the purchase is split, so network fee is applied to both instant and normal purchase
            var networkFeeValue: Decimal {
                guard dataStore?.from ?? 0 >= instantAchLimit && dataStore?.type != .sell else {
                    return dataStore?.networkFee?.fiatValue ?? 0
                }
                
                return 2 * (dataStore?.networkFee?.fiatValue ?? 0)
            }
            
            var depositQuantity = fromAmount + networkFeeValue + achFee
            if dataStore?.achDeliveryType == .instant {
                depositQuantity += instantAchFeeUsd
            }
            
            formattedDepositQuantity = fiatFormatter.string(from: depositQuantity as NSNumber) ?? ""
            formattedWithdrawalQuantity = cryptoFormatter.string(for: toAmount) ?? ""
        }
        
        let destination = dataStore?.type == .buy ? currency?.wallet?.defaultReceiveAddress : nil
        let cvv = dataStore?.type == .buy ? dataStore?.cvv?.description : nil
        let useInstantAch = dataStore?.type == .buy ? dataStore?.achDeliveryType == .instant : nil
        
        let data = AchExchangeRequestData(quoteId: dataStore?.quote?.quoteId,
                                          depositQuantity: formattedDepositQuantity,
                                          withdrawalQuantity: formattedWithdrawalQuantity,
                                          destination: destination,
                                          accountId: dataStore?.card?.id,
                                          nologCvv: cvv,
                                          useInstantAch: useInstantAch,
                                          secondFactorCode: dataStore?.secondFactorCode,
                                          secondFactorBackup: dataStore?.secondFactorBackup)
        
        AchExchangeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let exchangeData):
                self?.dataStore?.createTransactionModel?.exchange = exchangeData
                self?.dataStore?.paymentReference = exchangeData?.paymentReference
                guard let redirectUrlString = exchangeData?.redirectUrl, let redirectUrl = URL(string: redirectUrlString) else {
                    guard self?.dataStore?.type == .sell else {
                        self?.getData(viewAction: .init())
                        return
                    }
                    
                    self?.handleSellExchange()
                    return
                }
                
                ExchangeManager.shared.reload()
                self?.presenter?.presentThreeDSecure(actionResponse: .init(url: redirectUrl))
                
            case .failure(let error):
                guard let store = self?.dataStore,
                      let quoteId = store.quote?.quoteId,
                      (error as? NetworkingError)?.errorType == .biometricAuthentication else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                self?.presenter?.presentVeriffLivenessCheck(actionResponse: .init(quoteId: String(quoteId), isBiometric: true))
            }
        }
    }
    
    private func handleSellExchange() {
        createTransaction(viewAction: dataStore?.createTransactionModel) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentError(actionResponse: .init(error: error))
                return
            }
            
            self?.presenter?.presentSubmit(actionResponse: .init(paymentReference: self?.dataStore?.createTransactionModel?.exchange?.exchangeId,
                                                                 previewType: self?.dataStore?.type,
                                                                 isAch: self?.dataStore?.isAchAccount,
                                                                 achDeliveryType: self?.dataStore?.achDeliveryType,
                                                                 failed: false,
                                                                 responseCode: nil,
                                                                 errorDescription: nil))
        }
    }
    
    func changeAchDeliveryType(viewAction: OrderPreviewModels.SelectAchDeliveryType.ViewAction) {
        dataStore?.achDeliveryType = viewAction.achDeliveryType
        
        let item: Models.Item = (type: dataStore?.type,
                                 to: dataStore?.to,
                                 from: dataStore?.from,
                                 quote: dataStore?.quote,
                                 networkFee: dataStore?.networkFee,
                                 card: dataStore?.card,
                                 isAchAccount: dataStore?.isAchAccount,
                                 achDeliveryType: dataStore?.achDeliveryType)
        presenter?.presentPreview(actionRespone: .init(item: item))
    }
}
