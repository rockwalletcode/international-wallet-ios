// 
//  CreateTransactionVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 15/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

protocol CreateTransactionViewActions: BaseViewActions, FetchViewActions, FeeFetchable {
    func createTransaction(viewAction: CreateTransactionModels.Transaction.ViewAction?, completion: ((FEError?) -> Void)?)
    func getFees(viewAction: CreateTransactionModels.Fee.ViewAction, completion: ((Result<TransferFeeBasis, Error>) -> Void)?)
    func generateSender(viewAction: CreateTransactionModels.Sender.ViewAction)
}

protocol CreateTransactionDataStore: BaseDataStore, FetchDataStore {
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    var sender: Sender? { get set }
    var fromFeeBasis: TransferFeeBasis? { get set }
    var proTransfer: String? { get set }
    var senderValidationResult: SenderValidationResult? { get set }
}

struct XRPAttributeValidator {
    static func validate(from tag: String?, currency: Currency, completion: ((String?) -> Void)?) {
        // XRP destination Tag must fit into UInt32
        guard currency.isXRP, let attribute = tag, !attribute.isEmpty else { return }
        
        completion?(UInt32(attribute) == nil ? nil : attribute)
    }
}

struct XRPBalanceValidator {
    static func validate(balance: Amount?, amount: Amount?, currency: Currency?) -> String? {
        // XRP balance cannot be less than 10 after transaction (can change with time, update in constants when it does)
        guard let balance, let amount, let currency, currency.isXRP else { return nil }
        
        let message = L10n.ErrorMessages.Exchange.xrpMinimumReserve(Constant.xrpMinimumReserve)
        return balance - amount >= Amount(decimalAmount: 10, isFiat: false, currency: currency) ? nil : message
    }
}

extension Interactor where Self: CreateTransactionViewActions,
                           Self.DataStore: CreateTransactionDataStore {
    func createTransaction(viewAction: CreateTransactionModels.Transaction.ViewAction?, completion: ((FEError?) -> Void)?) {
        let currency = viewAction?.currencies?.first(where: { $0.code == viewAction?.proTransfer })
        guard let currency = currency,
              let fromFeeBasis = dataStore?.fromFeeBasis,
              let fromAmount = viewAction?.fromAmount?.tokenValue else { return }
        
        generateSender(viewAction: .init(fromAmountCurrency: currency))
        
        guard let sender = dataStore?.sender else {
            completion?(ExchangeErrors.noFees)
            return
        }
        
        let amount = Amount(decimalAmount: fromAmount, isFiat: false, currency: currency)
        let transaction = sender.createTransaction(address: viewAction?.address ?? "",
                                                   amount: amount,
                                                   feeBasis: fromFeeBasis,
                                                   proTransfer: viewAction?.proTransfer?.lowercased())
        
        var error: FEError?
        
        switch transaction {
        case .ok:
            sender.sendTransaction(allowBiometrics: false) { data in
                guard let pin: String = try? keychainItem(key: KeychainKey.pin) else {
                    completion?(ExchangeErrors.pinConfirmation)
                    return
                }
                data(pin)
            } completion: { result in
                defer {
                    sender.reset()
                }
                
                switch result {
                case .success:
                    ExchangeManager.shared.reload()
                    
                case .creationError(let message):
                    error = GeneralError(errorMessage: message)
                    
                case .insufficientGas:
                    error = ExchangeErrors.networkFee
                    
                case .publishFailure(let code, let message):
                    error = GeneralError(errorMessage: "\(L10n.Transaction.failed) \(code): \(message)")
                }
                
                completion?(error)
                
                return
            }
            
            return
            
        case .failed:
            error = GeneralError(errorMessage: L10n.ErrorMessages.unknownError)
            
        case .invalidAddress:
            error = GeneralError(errorMessage: L10n.UDomains.invalid)
            
        case .ownAddress:
            error = GeneralError(errorMessage: L10n.Send.containsAddress)
            
        case .insufficientFunds:
            error = ExchangeErrors.balanceTooLow(balance: fromAmount,
                                                 currency: currency.code)
            
        case .noExchangeRate:
            error = GeneralError(errorMessage: L10n.ErrorMessages.unknownError)
            
        case .noFees:
            error = ExchangeErrors.noFees
            
        case .outputTooSmall(let amount):
            error = ExchangeErrors.tooLow(amount: amount.tokenValue,
                                          currency: currency.code,
                                          reason: .swap)
            
        case .invalidRequest(let string):
            error = GeneralError(errorMessage: string)
            
        case .paymentTooSmall:
            error = ExchangeErrors.tooLow(amount: amount.tokenValue,
                                          currency: currency.code,
                                          reason: .swap)
            
        case .usedAddress:
            error = GeneralError(errorMessage: "Used address")
            
        case .identityNotCertified(let string):
            error = GeneralError(errorMessage: "Not certified \(string)")
            
        case .insufficientGas:
            error = ExchangeErrors.networkFee
            
        }
        
        completion?(error)
    }
    
    func generateSender(viewAction: CreateTransactionModels.Sender.ViewAction) {
        guard let fromCurrency = viewAction.fromAmountCurrency,
              let wallet = dataStore?.coreSystem?.wallet(for: fromCurrency),
              let keyStore = dataStore?.keyStore,
              let kvStore = Backend.kvStore else { return }
        
        let sender = Sender(wallet: wallet, authenticator: keyStore, kvStore: kvStore)
        sender.updateNetworkFees()
        
        dataStore?.sender = sender
    }
    
    func getFees(viewAction: CreateTransactionModels.Fee.ViewAction, completion: ((Result<TransferFeeBasis, Error>) -> Void)?) {
        guard let from = viewAction.fromAmount,
              let fromAddress = from.currency.wallet?.defaultReceiveAddress,
              let sender = dataStore?.sender else {
            dataStore?.fromFeeBasis = nil
            dataStore?.senderValidationResult = nil
            
            completion?(.failure(ExchangeErrors.noFees))
            
            return
        }
        
        fetchWalletKitFee(for: from,
                          with: sender,
                          address: fromAddress) { [weak self] result in
            switch result {
            case .success(let fee):
                self?.dataStore?.fromFeeBasis = fee
                self?.dataStore?.senderValidationResult = sender.validate(amount: from,
                                                                          feeBasis: self?.dataStore?.fromFeeBasis)
                
            default:
                break
            }
            
            completion?(result)
        }
    }
}
